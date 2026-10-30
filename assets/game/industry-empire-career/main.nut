// SPDX-License-Identifier: GPL-2.0-only
// All world and financial mutations use synchronized GameScript commands.
require("world.nut");

class FirstContract extends GSController {
    state = null;
    rendered_ledger = "";
    rendered_hint = "";
    function Save() { return this.state; }
    function Load(version, data) { this.state = data; }
}

function FirstContract::Cash(delta)
{
    return GSCompany.ChangeBankBalance(0, delta, GSCompany.EXPENSES_OTHER, GSMap.TILE_INVALID);
}

function FirstContract::Start()
{
    while (GSCompany.ResolveCompanyID(0) == GSCompany.COMPANY_INVALID) this.Sleep(1);
    if (this.state == null) {
        this.state = { version = 1, ready = false, message = "Preparing the first contract...", page = -1,
            ledger = -1, hint = -1, accept = -1, buy = -1, second = -1, skip = -1,
            skipped = false, contracts = [], revenue = 0, overhead = 0, penalties = 0,
            satisfaction = 100, last_date = GSDate.GetCurrentDate(), month = -1, purchased = 0,
            vehicles = [], world = null, inbox = 0 };
        this.state.world = CareerBuildWorld();
        if (this.state.world != null) {
            // OpenTTD's Money API uses GBP; USD is twice the internal amount.
            this.Cash(12500 - GSCompany.GetBankBalance(0));
            this.state.ready = true;
            this.state.message = "Read the offer, buy a grain truck, and start its repeating route.";
        } else {
            this.state.message = "No safe farm-to-receiver road could be prepared. No contract was activated. Try another Career map.";
        }
        this.state.last_date = GSDate.GetCurrentDate();
        this.state.month = GSDate.GetYear(this.state.last_date) * 12 + GSDate.GetMonth(this.state.last_date);
        this.BuildPage();
    }
    if (!GSStoryPage.IsValidStoryPage(this.state.page)) this.BuildPage();
    while (GSCompany.ResolveCompanyID(0) != GSCompany.COMPANY_INVALID) {
        if (this.state.ready) this.UpdateBusiness();
        this.Events();
        this.Render();
        this.Sleep(1);
    }
}

function FirstContract::BuildPage()
{
    local s = this.state;
    s.page = GSStoryPage.New(0, "Industry Empire | First Contract");
    GSStoryPage.NewElement(s.page, GSStoryPage.SPET_TEXT, 0,
        "FreshMart procurement: deliver grain to our receiving facility using real trucks and cargo. Purchase-first edition. " +
        "The existing factory represents the receiving facility; supermarket art and fresh produce are not yet implemented. " +
        "This edition uses 2 tonnes and calendar-day deadlines, not fractional tonnes or 06:00-09:00 appointments. " +
        "All figures below are USD equivalents; choose US Dollars in Game Options for matching finance displays.");
    GSStoryPage.NewElement(s.page, GSStoryPage.SPET_TEXT, 0,
        "Offer: 30 days, 2 tonnes delivered each day, $420 service bonus on a successful day. " +
        "A short/missed day costs $100 and 5 satisfaction. Success restores 2 satisfaction. " +
        "Normal cargo freight income and vehicle running costs still apply separately. Company overhead: $2,400 each calendar month. " +
        "A full truck counts only for the day it arrives; stock does not satisfy future delivery appointments. " +
        "Leasing and subcontracting are unavailable in this edition.");
    s.ledger = GSStoryPage.NewElement(s.page, GSStoryPage.SPET_TEXT, 0, "Preparing ledger...");
    s.hint = GSStoryPage.NewElement(s.page, GSStoryPage.SPET_TEXT, 0, "Preparing tutorial...");
    local style = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_YELLOW, GSStoryPage.SPBF_NONE);
    s.accept = GSStoryPage.NewElement(s.page, GSStoryPage.SPET_BUTTON_PUSH, style, "Accept FreshMart (starts tomorrow)");
    s.buy = GSStoryPage.NewElement(s.page, GSStoryPage.SPET_BUTTON_PUSH, style, "Buy grain truck and automate route");
    s.second = GSStoryPage.NewElement(s.page, GSStoryPage.SPET_BUTTON_PUSH, style, "Accept additional 4t/day allocation ($600/day)");
    s.skip = GSStoryPage.NewElement(s.page, GSStoryPage.SPET_BUTTON_PUSH, style, "Hide / show tutorial");
    if (s.ready) {
        GSStoryPage.NewElement(s.page, GSStoryPage.SPET_LOCATION, s.world.depot, "Company depot: inspect trucks, costs and orders");
        GSStoryPage.NewElement(s.page, GSStoryPage.SPET_LOCATION, s.world.farm_stop, "Farm loading bay");
        GSStoryPage.NewElement(s.page, GSStoryPage.SPET_LOCATION, s.world.receiver_stop, "FreshMart procurement receiving bay");
    }
    GSStoryPage.Show(s.page);
}

function FirstContract::Events()
{
    while (GSEventController.IsEventWaiting()) {
        local e = GSEventController.GetNextEvent();
        if (e.GetEventType() != GSEvent.ET_STORYPAGE_BUTTON_CLICK) continue;
        local click = GSEventStoryPageButtonClick.Convert(e);
        if (click.GetCompanyID() != 0 || click.GetStoryPageID() != this.state.page) continue;
        local id = click.GetElementID();
        if (id == this.state.skip) this.state.skipped = !this.state.skipped;
        if (!this.state.ready) continue;
        if (id == this.state.accept && this.state.contracts.len() == 0) this.Accept(2, 210);
        if (id == this.state.second && this.state.contracts.len() == 1) {
            if (this.state.contracts[0].success < 1) this.state.message = "Prove the route with one successful delivery day before taking on more volume.";
            else this.Accept(4, 300);
        }
        if (id == this.state.buy) this.Purchase();
    }
}

function FirstContract::Accept(units, payment)
{
    local s = this.state;
    if (s.contracts.len() == 0) GSCargoMonitor.GetIndustryDeliveryAmount(0, s.world.cargo, s.world.receiver, true);
    local start = GSDate.GetCurrentDate() + 1;
    s.contracts.append({ start = start, end = start + 30, units = units, payment = payment,
        delivered = 0, success = 0, missed = 0, settled = 0, last_settled = start - 1 });
    s.message = "Accepted. First deadline is the end of tomorrow. Existing deliveries cannot count toward this new allocation.";
}

function FirstContract::Purchase()
{
    local s = this.state;
    if (s.contracts.len() == 0) { s.message = "Accept the first offer before investing in a truck."; return; }
    local result = CareerBuyTruck(s.world);
    if (result == null) { s.message = "Truck purchase failed: " + GSError.GetLastErrorString() + ". Check cash, vehicle availability and depot access."; return; }
    s.vehicles.append(result.vehicle);
    s.purchased += result.cost;
    s.message = "Truck purchased. Its farm and receiving-bay orders repeat automatically. Open its orders to inspect or change the route.";
}

function FirstContract::UpdateBusiness()
{
    local s = this.state;
    local now = GSDate.GetCurrentDate();
    // Monitor counts only cargo accepted by the destination, not loading or transfers.
    local amount = s.contracts.len() > 0 ? GSCargoMonitor.GetIndustryDeliveryAmount(0, s.world.cargo, s.world.receiver, true) : 0;
    if (amount > 0) s.inbox += amount;
    // Settle older days before allocating newly observed arrivals. Polling is per GS tick.
    while (s.last_date < now) {
        foreach (c in s.contracts) {
            if (s.last_date < c.start || s.last_date >= c.end) continue;
            if (c.last_settled >= s.last_date) continue;
            local won = c.delivered >= c.units;
            local delta = won ? c.payment : -50;
            if (!this.Cash(delta)) { s.message = "Settlement paused: finance command failed."; return; }
            if (won) { c.success++; s.revenue += delta; s.satisfaction = min(100, s.satisfaction + 2); }
            else { c.missed++; s.penalties += 50; s.satisfaction = max(0, s.satisfaction - 5); }
            c.settled++;
            c.last_settled = s.last_date;
            c.delivered = 0;
        }
        s.last_date++;
    }
    foreach (c in s.contracts) {
        if (now < c.start || now >= c.end) continue;
        local assigned = min(s.inbox, max(0, c.units - c.delivered));
        c.delivered += assigned;
        s.inbox -= assigned; // A tonne cannot satisfy both overlapping contracts.
    }
    s.inbox = 0; // Extra tonnage does not prepay a future daily appointment.
    local month = GSDate.GetYear(now) * 12 + GSDate.GetMonth(now);
    while (s.month < month) {
        if (!this.Cash(-1200)) { s.message = "Overhead pending: finance command failed."; return; }
        s.overhead += 1200;
        s.month++;
    }
}

function FirstContract::Render()
{
    local s = this.state;
    local text = s.message + "\nCash: $" + (GSCompany.GetBankBalance(0) * 2) +
        " | Satisfaction: " + s.satisfaction + "/100\nContract bonuses: $" + (s.revenue * 2) +
        " | Overhead: $" + (s.overhead * 2) + " | Penalties: $" + (s.penalties * 2) +
        " | Truck purchases: $" + (s.purchased * 2) + "\nFreight income, running costs, interest and construction are itemized in Company Finances.";
    for (local i = 0; i < s.contracts.len(); i++) {
        local c = s.contracts[i];
        text += "\nAllocation " + (i + 1) + ": " + c.success + " successful, " + c.missed + " missed, " +
            (30 - c.settled) + " days remaining; today's cargo " + c.delivered + "/" + c.units + " tonnes.";
    }
    if (text != this.rendered_ledger) {
        if (GSStoryPage.UpdateElement(s.ledger, 0, text)) this.rendered_ledger = text;
    }
    local hint = "Tutorial hidden. Contract accounting continues.";
    if (!s.skipped) {
        hint = s.contracts.len() == 0 ? "1. Inspect the farm and receiving facility. Accept only when ready; the 30-day clock starts tomorrow." :
            (s.vehicles.len() == 0 ? "2. Buy a grain truck. The purchase is real and leaves less working cash for overhead. Its repeating orders are installed for you." :
            (s.contracts[0].success == 0 ? "3. Follow the truck: it must load grain, drive the road and unload at the receiving bay. Clicking buttons does not fulfill deliveries." :
            "4. Watch running costs and cash. The additional allocation competes for the same cargo: buy capacity only if the extra revenue covers it."));
    }
    if (hint != this.rendered_hint) {
        if (GSStoryPage.UpdateElement(s.hint, 0, hint)) this.rendered_hint = hint;
    }
}
