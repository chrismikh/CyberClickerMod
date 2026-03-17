module CyberClicker

import BrowserExtension.DataStructures.*
import BrowserExtension.Classes.*
import BrowserExtension.System.*

// Button controller with Hover (Tint) and Click (Scale) effects — silent hover
// ------------------------------------------------------------
public class CyberClickerButtonController extends inkLogicController {
  private let m_defaultColor: HDRColor;
  private let m_hoverColor: HDRColor;

  protected cb func OnInitialize() {
    this.m_hoverColor = new HDRColor(1.0, 1.0, 1.0, 1.0);
    this.RegisterToCallback(n"OnEnter", this, n"OnEnterCallback");
    this.RegisterToCallback(n"OnLeave", this, n"OnLeaveCallback");
    this.RegisterToCallback(n"OnPress", this, n"OnPressCallback");
    this.RegisterToCallback(n"OnRelease", this, n"OnReleaseCallback");
  }

  protected cb func OnEnterCallback(evt: ref<inkPointerEvent>) -> Bool {
    let w: ref<inkWidget> = this.GetRootWidget();
    this.m_defaultColor = w.GetTintColor();
    w.SetTintColor(this.m_hoverColor);
    return false;
  }

  protected cb func OnLeaveCallback(evt: ref<inkPointerEvent>) -> Bool {
    let w: ref<inkWidget> = this.GetRootWidget();
    w.SetTintColor(this.m_defaultColor);
    w.SetScale(new Vector2(1.0, 1.0));
    return false;
  }

  protected cb func OnPressCallback(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      let w: ref<inkWidget> = this.GetRootWidget();
      w.SetScale(new Vector2(0.9, 0.9));
    }
    return false;
  }

  protected cb func OnReleaseCallback(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      let w: ref<inkWidget> = this.GetRootWidget();
      w.SetScale(new Vector2(1.0, 1.0));
    }
    return false;
  }
}

// Menu button controller — hover with SFX
// ------------------------------------------------------------
public class CyberClickerMenuButtonController extends inkLogicController {
  private let m_defaultColor: HDRColor;
  private let m_hoverColor: HDRColor;

  private func PlayHoverSfx(sound: CName) -> Void {
    let player: wref<PlayerPuppet> = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
      return;
    }

    let evt: ref<AudioEvent> = new AudioEvent();
    evt.eventName = sound;
    player.QueueEvent(evt);
  }

  protected cb func OnInitialize() {
    this.m_hoverColor = new HDRColor(1.0, 1.0, 1.0, 1.0);
    this.RegisterToCallback(n"OnEnter", this, n"OnEnterCallback");
    this.RegisterToCallback(n"OnLeave", this, n"OnLeaveCallback");
    this.RegisterToCallback(n"OnPress", this, n"OnPressCallback");
    this.RegisterToCallback(n"OnRelease", this, n"OnReleaseCallback");
  }

  protected cb func OnEnterCallback(evt: ref<inkPointerEvent>) -> Bool {
    let w: ref<inkWidget> = this.GetRootWidget();
    this.m_defaultColor = w.GetTintColor();
    w.SetTintColor(this.m_hoverColor);
    this.PlayHoverSfx(n"ui_menu_hover");
    return false;
  }

  protected cb func OnLeaveCallback(evt: ref<inkPointerEvent>) -> Bool {
    let w: ref<inkWidget> = this.GetRootWidget();
    w.SetTintColor(this.m_defaultColor);
    w.SetScale(new Vector2(1.0, 1.0));
    return false;
  }

  protected cb func OnPressCallback(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      let w: ref<inkWidget> = this.GetRootWidget();
      w.SetScale(new Vector2(0.9, 0.9));
    }
    return false;
  }

  protected cb func OnReleaseCallback(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      let w: ref<inkWidget> = this.GetRootWidget();
      w.SetScale(new Vector2(1.0, 1.0));
    }
    return false;
  }
}

// Delay callbacks
// ------------------------------------------------------------
public class CyberClickerTickCallback extends DelayCallback {
  public let site: wref<CyberClickerSiteListener>;
  public func Call() -> Void { if IsDefined(this.site) { this.site.OnTick(); } }
}

public class CyberClickerClearMsgCallback extends DelayCallback {
  public let site: wref<CyberClickerSiteListener>;
  public func Call() -> Void { if IsDefined(this.site) { this.site.ClearMessage(); } }
}

// Main site listener
// ------------------------------------------------------------
public class CyberClickerSiteListener extends BrowserEventsListener {
  private let m_mainAddr: String;
  private let m_shopAddr: String;
  private let m_redeemAddr: String;
  private let m_generatorsAddr: String;
  private let m_upgradesAddr: String;
  private let m_achievementsAddr: String;
  
  private let m_currentRoot: wref<inkWidget>;
  private let m_currentAddr: String;

  private let m_lastMsg: String;
  private let m_lastMsgOk: Bool;
  private let m_msgDelayID: DelayID;
  private let m_stagedRedeemPoints: Int32;
  private let m_tickSec: Float = 2.0;
  private let m_tickRunning: Bool;
  private let m_lastUnclaimedAchCount: Int32;

  // Pending away message (shown only when user visits the site)
  private let m_pendingAwayMsg: String;
  private let m_hasPendingAwayMsg: Bool;
  private let m_awayCalculated: Bool;

  // Cached widget references for stateful UI updates
  private let m_pointsText: wref<inkText>;
  private let m_statsText: wref<inkText>;
  private let m_msgText: wref<inkText>;
  private let m_stagedText: wref<inkText>;
  private let m_btn1k: wref<inkText>;
  private let m_btn10k: wref<inkText>;
  private let m_btn100k: wref<inkText>;
  private let m_resetBtn: wref<inkText>;
  private let m_confirmBtn: wref<inkText>;

  // Achievements helper (separate class)
  private let m_achievements: ref<CyberClickerAchievements>;

  // Cached colors
  private let m_colCyan: HDRColor;
  private let m_colRed: HDRColor;
  private let m_colGreen: HDRColor;
  private let m_colGray: HDRColor;
  private let m_colDarkGray: HDRColor;
  private let m_colHeader: HDRColor;
  private let m_colGold: HDRColor;

  // Colors
  public func ColCyan() -> HDRColor { return this.m_colCyan; }
  public func ColRed() -> HDRColor { return this.m_colRed; }
  public func ColGreen() -> HDRColor { return this.m_colGreen; }
  public func ColGray() -> HDRColor { return this.m_colGray; }
  public func ColDarkGray() -> HDRColor { return this.m_colDarkGray; }
  public func ColHeader() -> HDRColor { return this.m_colHeader; }
  public func ColGold() -> HDRColor { return this.m_colGold; }

  // Achievement API (accessed by CyberClickerAchievements)
  public func SetMsgTextWidget(t: wref<inkText>) -> Void { this.m_msgText = t; }
  public func GetLastMsg() -> String { return this.m_lastMsg; }
  public func IsLastMsgOk() -> Bool { return this.m_lastMsgOk; }
  public func ReloadCurrentPage() -> Void { this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); }

  public func Init(logic: ref<BrowserGameController>) {
    super.Init(logic);
    this.m_colCyan = new HDRColor(0.368627, 0.964706, 1.0, 1.0);
    this.m_colRed = new HDRColor(1.0, 0.4, 0.4, 1.0);
    this.m_colGreen = new HDRColor(0.5, 1.0, 0.5, 1.0);
    this.m_colGray = new HDRColor(0.5, 0.5, 0.5, 1.0);
    this.m_colDarkGray = new HDRColor(0.2, 0.2, 0.2, 1.0);
    this.m_colHeader = new HDRColor(1.1761, 0.3809, 0.3476, 1.0);
    this.m_colGold = new HDRColor(1.8, 1.4, 0.3, 1.0);

    this.m_mainAddr = s"NETdir://cyber.clicker";
    this.m_shopAddr = s"NETdir://cyber.clicker/shop";
    this.m_redeemAddr = s"NETdir://cyber.clicker/redeem";
    this.m_generatorsAddr = s"NETdir://cyber.clicker/generators";
    this.m_upgradesAddr = s"NETdir://cyber.clicker/upgrades";
    this.m_achievementsAddr = s"NETdir://cyber.clicker/achievements";

    this.m_siteData.address = this.m_mainAddr;
    this.m_siteData.shortName = CyberClickerLoc.SiteShortName();
    this.m_siteData.iconAtlasPath = r"cyberClicker\\ui\\logo\\cyberclickermodlogo_icon.inkatlas";
    this.m_siteData.iconTexturePart = n"cyberclickerbrowsericon";

    this.m_lastMsg = s"";
    this.m_lastMsgOk = true;
    this.m_stagedRedeemPoints = 0;
    this.m_pendingAwayMsg = s"";
    this.m_hasPendingAwayMsg = false;
    this.m_awayCalculated = false;

    this.EnsureDefaults();

    this.m_achievements = new CyberClickerAchievements();
    this.m_achievements.Init(this);

    this.m_tickRunning = false;
  }

  public func Uninit() {
    this.m_tickRunning = false;
    super.Uninit();
  }

  // Calculate away progress — only called when user visits the CyberClicker site
  private func CalculateAwayProgress() -> Void {
    if this.m_awayCalculated { return; }
    this.m_awayCalculated = true;

    let timeSystem = GameInstance.GetTimeSystem(GetGameInstance());
    if !IsDefined(timeSystem) { return; }

    let nowTimeSeconds: Int32 = GameTime.GetSeconds(timeSystem.GetGameTime());
    let lastTimeSeconds: Int32 = this.GetFactOrDefault(CyberClickerFacts.LastGameTime(), 0);

    if lastTimeSeconds > 0 && nowTimeSeconds > lastTimeSeconds {
      let elapsedSeconds: Int32 = nowTimeSeconds - lastTimeSeconds;
      let capHours: Int32 = this.GetCapacityHours();
      let maxSeconds: Int32 = capHours * 3600;
      let added: Int32 = this.ApplyAutoEarnings(maxSeconds);

      if added > 0 {
        if elapsedSeconds > maxSeconds {
          let awR = StrReplace(CyberClickerLoc.AwayMsgCapReached(), "{amount}", IntToString(added));
          this.m_pendingAwayMsg = StrReplace(awR, "{cap}", IntToString(capHours));
        } else {
          let cappedMinutes: Int32 = elapsedSeconds / 60;
          if cappedMinutes >= 60 {
            let awR = StrReplace(CyberClickerLoc.AwayMsgHoursElapsed(), "{amount}", IntToString(added));
            this.m_pendingAwayMsg = StrReplace(awR, "{hours}", IntToString(cappedMinutes / 60));
          } else {
            this.m_pendingAwayMsg = StrReplace(CyberClickerLoc.AwayMsgWhileAway(), "{amount}", IntToString(added));
          }
        }
        this.m_hasPendingAwayMsg = true;
      }
    } else if nowTimeSeconds > 0 && lastTimeSeconds == 0 {
      this.SetFact(CyberClickerFacts.LastGameTime(), nowTimeSeconds);
    }
  }

  // Fact helpers
  // ----------------------------
  private func QS() -> ref<QuestsSystem> { return GameInstance.GetQuestsSystem(GetGameInstance()); }
  public func GetFactOrDefault(name: CName, def: Int32) -> Int32 { let qs = this.QS(); if !IsDefined(qs) { return def; } return qs.GetFact(name); }
  public func SetFact(name: CName, v: Int32) -> Void { let qs = this.QS(); if IsDefined(qs) { qs.SetFact(name, v); } }
  public func ClampPoints(v: Int32) -> Int32 { if v < 0 { return 0; } if v > 2000000000 { return 2000000000; } return v; }
  private func ExpCost(base: Float, rate: Float, lvl: Int32) -> Int32 { let f: Float = base * PowF(rate, Cast<Float>(lvl)); if f > 2000000000.0 { return 2000000000; } return Cast<Int32>(f); }

  private func EnsureDefaults() -> Void {
    if this.GetFactOrDefault(CyberClickerFacts.Points(), 0) < 0 { this.SetFact(CyberClickerFacts.Points(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.Capacity(), 0) < 0 { this.SetFact(CyberClickerFacts.Capacity(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0) < 0 { this.SetFact(CyberClickerFacts.T1Bots(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0) < 0 { this.SetFact(CyberClickerFacts.T2Bots(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0) < 0 { this.SetFact(CyberClickerFacts.T3Bots(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0) < 0 { this.SetFact(CyberClickerFacts.T4Bots(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T1Clicks(), 0) < 0 { this.SetFact(CyberClickerFacts.T1Clicks(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T2Clicks(), 0) < 0 { this.SetFact(CyberClickerFacts.T2Clicks(), 0); }
    if this.GetFactOrDefault(CyberClickerFacts.T3Clicks(), 0) < 0 { this.SetFact(CyberClickerFacts.T3Clicks(), 0); }
  }

  // Auto-earnings helper — applies elapsed auto-production, returns points added.
  // capSeconds > 0 limits elapsed time considered; <= 0 means no cap.
  private func ApplyAutoEarnings(capSeconds: Int32) -> Int32 {
    let timeSystem = GameInstance.GetTimeSystem(GetGameInstance());
    if !IsDefined(timeSystem) { return 0; }
    let now: Int32 = GameTime.GetSeconds(timeSystem.GetGameTime());
    let last: Int32 = this.GetFactOrDefault(CyberClickerFacts.LastGameTime(), 0);
    if last <= 0 || now <= last { return 0; }
    let elapsed: Int32 = now - last;
    let effective: Int32 = elapsed;
    if capSeconds > 0 && effective > capSeconds { effective = capSeconds; }
    let mins: Int32 = effective / 60;
    let aut: Int32 = this.GetTotalAutoPerMin();
    if aut <= 0 || mins <= 0 { return 0; }
    let pts: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    let addF: Float = Cast<Float>(mins) * Cast<Float>(aut);
    let maxF: Float = Cast<Float>(2000000000 - pts);
    let added: Int32 = 0;
    if addF > maxF { added = 2000000000 - pts; } else { added = Cast<Int32>(addF); }
    this.SetFact(CyberClickerFacts.Points(), pts + added);
    let consumedSec: Int32 = (elapsed / 60) * 60;
    this.SetFact(CyberClickerFacts.LastGameTime(), last + consumedSec);
    return added;
  }

  // Economy Math
  // ----------------------------
  private func GetBotMilestoneMult(count: Int32) -> Int32 {
      let m: Int32 = 1;
      if count >= 10 { m *= 2; }
      if count >= 25 { m *= 2; }
      if count >= 50 { m *= 2; }
      if count >= 100 { m *= 2; }
      return m;
  }

  private func GetNextMilestoneStr(count: Int32) -> String {
      if count < 10  { return this.FmtMilestoneNext(2, 10 - count); }
      if count < 25  { return this.FmtMilestoneNext(4, 25 - count); }
      if count < 50  { return this.FmtMilestoneNext(8, 50 - count); }
      if count < 100 { return this.FmtMilestoneNext(16, 100 - count); }
      return CyberClickerLoc.MilestoneMax();
  }

  public func GetTotalAutoPerMin() -> Int32 {
      let t1 = this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0);
      let t2 = this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
      let t3 = this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
      let t4 = this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
      return (t1 * 1 * this.GetBotMilestoneMult(t1)) + (t2 * 5 * this.GetBotMilestoneMult(t2)) + (t3 * 25 * this.GetBotMilestoneMult(t3)) + (t4 * 125 * this.GetBotMilestoneMult(t4));
  }

  public func GetTotalPPC() -> Int32 {
      let t1 = this.GetFactOrDefault(CyberClickerFacts.T1Clicks(), 0);
      let t2 = this.GetFactOrDefault(CyberClickerFacts.T2Clicks(), 0);
      let t3 = this.GetFactOrDefault(CyberClickerFacts.T3Clicks(), 0);
      return 1 + (t1 * 1) + (t2 * 5) + (t3 * 25);
  }

  public func GetCapacityHours() -> Int32 { return 4 + this.GetFactOrDefault(CyberClickerFacts.Capacity(), 0); }

  public func GetTotalBots() -> Int32 {
    return this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0) + this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0) + this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0) + this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
  }

  public func GetUnclaimedAchCount() -> Int32 { return this.m_achievements.GetUnclaimedAchCount(); }

  // Localization Format Helpers
  // ----------------------------
  private func FmtStatsBlock(ppc: Int32, t1b: Int32, t1p: Int32, t2b: Int32, t2p: Int32, t3b: Int32, t3p: Int32, t4b: Int32, t4p: Int32, autoPerMin: Int32, capHours: Int32) -> String {
    let t = CyberClickerLoc.StatsBlock();
    let r1 = StrReplace(t, "{ppc}", IntToString(ppc));
    let r2 = StrReplace(r1, "{t1b}", IntToString(t1b));
    let r3 = StrReplace(r2, "{t1p}", IntToString(t1p));
    let r4 = StrReplace(r3, "{t2b}", IntToString(t2b));
    let r5 = StrReplace(r4, "{t2p}", IntToString(t2p));
    let r6 = StrReplace(r5, "{t3b}", IntToString(t3b));
    let r7 = StrReplace(r6, "{t3p}", IntToString(t3p));
    let r8 = StrReplace(r7, "{t4b}", IntToString(t4b));
    let r9 = StrReplace(r8, "{t4p}", IntToString(t4p));
    let r10 = StrReplace(r9, "{auto}", IntToString(autoPerMin));
    return StrReplace(r10, "{cap}", IntToString(capHours));
  }

  private func FmtRedeemStaged(points: Int32, eddies: Int32) -> String {
    let r = StrReplace(CyberClickerLoc.RedeemStaged(), "{points}", IntToString(points));
    return StrReplace(r, "{eddies}", IntToString(eddies));
  }

  private func FmtGenBotEntry(name: String, count: Int32, mult: Int32, milestone: String, cost: Int32) -> String {
    let t = CyberClickerLoc.GenBotEntry();
    let r1 = StrReplace(t, "{name}", name);
    let r2 = StrReplace(r1, "{count}", IntToString(count));
    let r3 = StrReplace(r2, "{mult}", IntToString(mult));
    let r4 = StrReplace(r3, "{milestone}", milestone);
    return StrReplace(r4, "{cost}", IntToString(cost));
  }

  private func FmtUpgClickEntry(name: String, bonus: Int32, lvl: Int32, cost: Int32) -> String {
    let t = CyberClickerLoc.UpgClickEntry();
    let r1 = StrReplace(t, "{name}", name);
    let r2 = StrReplace(r1, "{bonus}", IntToString(bonus));
    let r3 = StrReplace(r2, "{lvl}", IntToString(lvl));
    return StrReplace(r3, "{cost}", IntToString(cost));
  }

  private func FmtMilestoneNext(multiplier: Int32, remaining: Int32) -> String {
    let r = StrReplace(CyberClickerLoc.MilestoneNext(), "{mult}", IntToString(multiplier));
    return StrReplace(r, "{remaining}", IntToString(remaining));
  }

  // Redeem rate based on Street Cred
  private func GetRedeemRate() -> Int32 {
    let player: wref<PlayerPuppet> = GetPlayer(GetGameInstance());
    if IsDefined(player) {
      let ss: ref<StatsSystem> = GameInstance.GetStatsSystem(GetGameInstance());
      if !IsDefined(ss) { return 1000; }
      let sc: Float = ss.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.StreetCred);
      if sc > 35.0 { return 750; }
      if sc > 20.0 { return 850; }
    }
    return 1000;
  }

  // Costs
  private func CostBotT1(count: Int32) -> Int32 { return this.ExpCost(100.0, 1.10, count); }
  private func CostBotT2(count: Int32) -> Int32 { return this.ExpCost(1500.0, 1.10, count); }
  private func CostBotT3(count: Int32) -> Int32 { return this.ExpCost(20000.0, 1.10, count); }
  private func CostBotT4(count: Int32) -> Int32 { return this.ExpCost(100000.0, 1.10, count); }
  private func CostClickT1(lvl: Int32) -> Int32 { return this.ExpCost(300.0, 1.10, lvl); }
  private func CostClickT2(lvl: Int32) -> Int32 { return this.ExpCost(4500.0, 1.07, lvl); }
  private func CostClickT3(lvl: Int32) -> Int32 { return this.ExpCost(60000.0, 1.12, lvl); }
  private func CostCapacity(lvl: Int32) -> Int32 { let l = lvl + 1; return 2000 * l * l; }

  private func TrySpendPoints(cost: Int32, what: String) -> Bool {
    if cost <= 0 { this.ShowMessage(CyberClickerLoc.MsgInvalidCost(), false); return false; }
    let pts: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    if pts < cost { this.ShowMessage(StrReplace(CyberClickerLoc.MsgNotEnoughData(), "{cost}", IntToString(cost)), false); return false; }
    
    this.SetFact(CyberClickerFacts.Points(), this.ClampPoints(pts - cost));
    let r = StrReplace(CyberClickerLoc.MsgPurchased(), "{what}", what);
    this.ShowMessage(StrReplace(r, "{cost}", IntToString(cost)), true);
    return true;
  }

  public func GivePlayerMoney(amount: Int32) -> Void {
    if amount <= 0 { return; }
    let gi = GetGameInstance();
    let ts = GameInstance.GetTransactionSystem(gi);
    let ps = GameInstance.GetPlayerSystem(gi);
    if IsDefined(ts) && IsDefined(ps) {
      let player: ref<GameObject> = ps.GetLocalPlayerMainGameObject();
      if IsDefined(player) { ts.GiveItem(player, ItemID.CreateQuery(t"Items.money"), amount); }
    }
  }

  public func ShowMessage(msg: String, isOk: Bool) -> Void {
    this.m_lastMsg = msg;
    this.m_lastMsgOk = isOk;
    let delay = GameInstance.GetDelaySystem(GetGameInstance());
    if IsDefined(delay) {
      delay.CancelDelay(this.m_msgDelayID); 
      let cb: ref<CyberClickerClearMsgCallback> = new CyberClickerClearMsgCallback();
      cb.site = this;
      this.m_msgDelayID = delay.DelayCallback(cb, 3.0);
    }
  }

  public func ClearMessage() -> Void {
    if StrLen(this.m_lastMsg) > 0 {
        this.m_lastMsg = s"";
        this.RefreshUI();
    }
  }

  // Text widget factory
  public func MakeText(text: String, size: Int32, style: CName, color: HDRColor) -> ref<inkText> {
    let t: ref<inkText> = new inkText();
    t.SetText(text);
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(style);
    t.SetFontSize(size);
    t.SetTintColor(color);
    t.SetFitToContent(true);
    return t;
  }

  // Stateful UI refresh (no widget rebuild)
  // ----------------------------
  private func RefreshUI() -> Void {
    if IsDefined(this.m_pointsText) {
      let pts: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_pointsText.SetText(IntToString(pts) + CyberClickerLoc.DataSuffix());
    }
    if IsDefined(this.m_msgText) {
      if StrLen(this.m_lastMsg) > 0 { this.m_msgText.SetText(this.m_lastMsg); } else { this.m_msgText.SetText(" "); }
      this.m_msgText.SetTintColor(this.m_lastMsgOk ? this.m_colGreen : this.m_colRed);
    }
    if IsDefined(this.m_statsText) {
      let t1b: Int32 = this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0);
      let t2b: Int32 = this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
      let t3b: Int32 = this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
      let t4b: Int32 = this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
      let t1p: Int32 = t1b * 1 * this.GetBotMilestoneMult(t1b);
      let t2p: Int32 = t2b * 5 * this.GetBotMilestoneMult(t2b);
      let t3p: Int32 = t3b * 25 * this.GetBotMilestoneMult(t3b);
      let t4p: Int32 = t4b * 125 * this.GetBotMilestoneMult(t4b);
      this.m_statsText.SetText(
        this.FmtStatsBlock(this.GetTotalPPC(), t1b, t1p, t2b, t2p, t3b, t3p, t4b, t4p, this.GetTotalAutoPerMin(), this.GetCapacityHours())
      );
    }
    let rate: Int32 = this.GetRedeemRate();
    if IsDefined(this.m_stagedText) {
      this.m_stagedText.SetText(this.FmtRedeemStaged(this.m_stagedRedeemPoints, this.m_stagedRedeemPoints / rate));
    }
    let pts2: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    let space: Int32 = pts2 - this.m_stagedRedeemPoints;
    let hasStaged: Bool = this.m_stagedRedeemPoints > 0;
    if IsDefined(this.m_btn1k) {
      let on: Bool = space >= rate;
      this.m_btn1k.SetText("[ +" + IntToString(rate) + " ]");
      this.m_btn1k.SetTintColor(on ? this.m_colCyan : this.m_colDarkGray);
      this.m_btn1k.SetInteractive(on);
    }
    if IsDefined(this.m_btn10k) {
      let on: Bool = space >= (rate * 10);
      this.m_btn10k.SetText("[ +" + IntToString(rate * 10) + " ]");
      this.m_btn10k.SetTintColor(on ? this.m_colCyan : this.m_colDarkGray);
      this.m_btn10k.SetInteractive(on);
    }
    if IsDefined(this.m_btn100k) {
      let on: Bool = space >= (rate * 100);
      this.m_btn100k.SetText("[ +" + IntToString(rate * 100) + " ]");
      this.m_btn100k.SetTintColor(on ? this.m_colCyan : this.m_colDarkGray);
      this.m_btn100k.SetInteractive(on);
    }
    if IsDefined(this.m_resetBtn) {
      this.m_resetBtn.SetTintColor(hasStaged ? this.m_colCyan : this.m_colDarkGray);
      this.m_resetBtn.SetInteractive(hasStaged);
    }
    if IsDefined(this.m_confirmBtn) {
      this.m_confirmBtn.SetTintColor(hasStaged ? this.m_colCyan : this.m_colDarkGray);
      this.m_confirmBtn.SetInteractive(hasStaged);
    }
  }

  // Passive tick 
  // ----------------------------
  private func ScheduleNextTick() -> Void {
    if !this.m_tickRunning { return; }
    let delay = GameInstance.GetDelaySystem(GetGameInstance());
    if !IsDefined(delay) { return; }
    let cb: ref<CyberClickerTickCallback> = new CyberClickerTickCallback();
    cb.site = this;
    delay.DelayCallback(cb, this.m_tickSec);
  }

  public func OnTick() -> Void {
    if !this.m_tickRunning { return; }
    if !IsDefined(this.m_currentRoot) { this.m_tickRunning = false; return; }

    let added: Int32 = this.ApplyAutoEarnings(0);
    if added > 0 { this.RefreshUI(); }

    let currentUnclaimed: Int32 = this.GetUnclaimedAchCount();
    if currentUnclaimed != this.m_lastUnclaimedAchCount {
      this.m_lastUnclaimedAchCount = currentUnclaimed;
      this.ReloadCurrentPage();
    }

    this.ScheduleNextTick();
  }

  // UI style helpers
  // ----------------------------
  private func StyleTitle(t: ref<inkText>) -> Void {
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(n"Bold");
    t.SetFontSize(90);
    t.SetTintColor(this.m_colHeader);
    t.SetHAlign(inkEHorizontalAlign.Center);
    t.SetFitToContent(true);
  }

  public func StyleButton(t: ref<inkText>, isAffordable: Bool) -> Void {
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(n"Bold");
    t.SetFontSize(80);
    t.SetHAlign(inkEHorizontalAlign.Center);
    t.SetFitToContent(true);
    if isAffordable {
      t.SetTintColor(this.m_colCyan);
      t.SetInteractive(true);
      t.AttachController(new CyberClickerMenuButtonController());
    } else {
      t.SetTintColor(this.m_colDarkGray);
      t.SetInteractive(false);
    }
  }

  private func StyleShopButton(t: ref<inkText>, isAffordable: Bool) -> Void {
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(n"Semi-Bold");
    t.SetFontSize(58);
    t.SetHAlign(inkEHorizontalAlign.Left);
    t.SetFitToContent(true);
    if isAffordable {
      t.SetTintColor(this.m_colCyan);
      t.SetInteractive(true);
      t.AttachController(new CyberClickerMenuButtonController());
    } else {
      t.SetTintColor(this.m_colDarkGray);
      t.SetInteractive(false);
    }
  }

  private func StyleShopHeader(t: ref<inkText>) -> Void {
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(n"Bold");
    t.SetFontSize(70);
    t.SetTintColor(this.m_colHeader);
    t.SetHAlign(inkEHorizontalAlign.Left);
    t.SetFitToContent(true);
  }

  // Pages
  // ----------------------------
  public func GetWebPage(address: String) -> ref<inkCompoundWidget> {
    this.EnsureDefaults();
    this.m_currentAddr = address;
    this.m_pointsText = null;
    this.m_statsText = null;
    this.m_msgText = null;
    this.m_stagedText = null;
    this.m_btn1k = null;
    this.m_btn10k = null;
    this.m_btn100k = null;
    this.m_resetBtn = null;
    this.m_confirmBtn = null;

    // Calculate away progress on first visit this session
    this.CalculateAwayProgress();

    // Show pending away message
    if this.m_hasPendingAwayMsg {
      this.m_lastMsg = this.m_pendingAwayMsg;
      this.m_lastMsgOk = true;
      this.m_hasPendingAwayMsg = false;
      this.m_pendingAwayMsg = s"";
      let delay = GameInstance.GetDelaySystem(GetGameInstance());
      if IsDefined(delay) { delay.CancelDelay(this.m_msgDelayID); }
    }

    let canvas: ref<inkCanvas> = new inkCanvas();
    canvas.SetFitToContent(false);
    this.m_currentRoot = canvas;

    // Start tick if not running; catch up any gap
    if !this.m_tickRunning {
      this.ApplyAutoEarnings(0);
      this.m_tickRunning = true;
      this.ScheduleNextTick();
    }

    // ACHIEVEMENTS PAGE
    if Equals(address, this.m_achievementsAddr) {
      this.m_achievements.BuildAchievementsPage(canvas);
      return canvas;
    }

    // Shared layout: stats column + center column
    let pts: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    this.BuildStatsColumn(canvas);
    let centerCol: ref<inkVerticalPanel> = this.BuildCenterColumn(canvas, pts);

    if Equals(address, this.m_mainAddr) { this.BuildMainPage(centerCol); }
    else if Equals(address, this.m_redeemAddr) { this.BuildRedeemPage(canvas, centerCol); }
    else if Equals(address, this.m_shopAddr) { this.BuildShopMenuPage(canvas, centerCol); }
    else if Equals(address, this.m_generatorsAddr) { this.BuildGeneratorsPage(canvas, centerCol, pts); }
    else if Equals(address, this.m_upgradesAddr) { this.BuildUpgradesPage(canvas, centerCol, pts); }

    return canvas;
  }

  private func BuildStatsColumn(canvas: ref<inkCanvas>) -> Void {
    let t1b = this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0);
    let t2b = this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
    let t3b = this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
    let t4b = this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
    let t1p = t1b * 1 * this.GetBotMilestoneMult(t1b);
    let t2p = t2b * 5 * this.GetBotMilestoneMult(t2b);
    let t3p = t3b * 25 * this.GetBotMilestoneMult(t3b);
    let t4p = t4b * 125 * this.GetBotMilestoneMult(t4b);

    let leftCol: ref<inkVerticalPanel> = new inkVerticalPanel();
    leftCol.SetAnchor(inkEAnchor.TopLeft);
    leftCol.SetAnchorPoint(new Vector2(0.0, 0.0));
    leftCol.SetMargin(new inkMargin(50.0, 100.0, 0.0, 0.0));
    leftCol.SetChildMargin(new inkMargin(0.0, 20.0, 0.0, 20.0));
    leftCol.SetFitToContent(true);
    leftCol.Reparent(canvas);

    let statsHeader = this.MakeText(CyberClickerLoc.StatsHeader(), 60, n"Bold", this.m_colCyan);
    statsHeader.Reparent(leftCol);

    let statsInfo = this.MakeText(
      this.FmtStatsBlock(this.GetTotalPPC(), t1b, t1p, t2b, t2p, t3b, t3p, t4b, t4p, this.GetTotalAutoPerMin(), this.GetCapacityHours()),
      55, n"Semi-Bold", this.m_colGray
    );
    statsInfo.Reparent(leftCol);
    this.m_statsText = statsInfo;

    let unclaimedCount: Int32 = this.GetUnclaimedAchCount();
    this.m_lastUnclaimedAchCount = unclaimedCount;
    let achBtn: ref<inkText>;
    if unclaimedCount > 0 {
      achBtn = this.MakeText(StrReplace(CyberClickerLoc.BtnAchievementsWithCount(), "{n}", IntToString(unclaimedCount)), 55, n"Bold", this.m_colGreen);
    } else {
      achBtn = this.MakeText(CyberClickerLoc.BtnAchievements(), 55, n"Bold", this.m_colCyan);
    }
    achBtn.SetHAlign(inkEHorizontalAlign.Left);
    achBtn.SetInteractive(true);
    achBtn.AttachController(new CyberClickerMenuButtonController());
    achBtn.RegisterToCallback(n"OnRelease", this, n"OnGoAchievementsPressed");
    achBtn.Reparent(leftCol);
  }

  private func BuildCenterColumn(canvas: ref<inkCanvas>, pts: Int32) -> ref<inkVerticalPanel> {
    let centerCol: ref<inkVerticalPanel> = new inkVerticalPanel();
    centerCol.SetAnchor(inkEAnchor.TopCenter);
    centerCol.SetAnchorPoint(new Vector2(0.5, 0.0));
    centerCol.SetMargin(new inkMargin(0.0, 100.0, 0.0, 0.0));
    centerCol.SetFitToContent(true);
    centerCol.SetChildMargin(new inkMargin(0.0, 25.0, 0.0, 25.0));
    centerCol.Reparent(canvas);

    let title = this.MakeText(CyberClickerLoc.PageTitleMain(), 90, n"Bold", this.m_colHeader);
    title.SetHAlign(inkEHorizontalAlign.Center);
    title.Reparent(centerCol);

    let pointsDisplay = this.MakeText(IntToString(pts) + CyberClickerLoc.DataSuffix(), 72, n"Bold", this.m_colGold);
    pointsDisplay.SetHAlign(inkEHorizontalAlign.Center);
    pointsDisplay.Reparent(centerCol);
    this.m_pointsText = pointsDisplay;

    let msg: ref<inkText>;
    if StrLen(this.m_lastMsg) > 0 {
      msg = this.MakeText(this.m_lastMsg, 55, n"Regular", this.m_lastMsgOk ? this.m_colGreen : this.m_colRed);
    } else {
      msg = this.MakeText(" ", 55, n"Regular", this.m_colGreen);
    }
    msg.SetHAlign(inkEHorizontalAlign.Center);
    msg.Reparent(centerCol);
    this.m_msgText = msg;

    return centerCol;
  }

  private func BuildMainPage(centerCol: ref<inkVerticalPanel>) -> Void {
    let clickImg: ref<inkImage> = new inkImage();
    clickImg.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas");
    clickImg.SetTexturePart(n"ico_int");
    clickImg.SetHAlign(inkEHorizontalAlign.Center);
    clickImg.SetAnchorPoint(new Vector2(0.5, 0.5));
    clickImg.SetSize(new Vector2(256.0, 256.0));
    clickImg.SetTintColor(this.m_colCyan);
    clickImg.SetInteractive(true);
    clickImg.SetFitToContent(false);
    clickImg.AttachController(new CyberClickerButtonController());
    clickImg.RegisterToCallback(n"OnRelease", this, n"OnClickPressed");
    clickImg.Reparent(centerCol);

    let shopBtn = new inkText(); shopBtn.SetText(CyberClickerLoc.BtnSystemUpgrades()); this.StyleButton(shopBtn, true);
    shopBtn.RegisterToCallback(n"OnRelease", this, n"OnGoShopPressed"); shopBtn.Reparent(centerCol);

    let redeemBtn = new inkText(); redeemBtn.SetText(CyberClickerLoc.BtnRedeemYourData()); this.StyleButton(redeemBtn, true);
    redeemBtn.RegisterToCallback(n"OnRelease", this, n"OnGoRedeemPressed"); redeemBtn.Reparent(centerCol);
  }

  private func BuildRedeemPage(canvas: ref<inkCanvas>, centerCol: ref<inkVerticalPanel>) -> Void {
    let rate: Int32 = this.GetRedeemRate();
    let infoText = this.MakeText(CyberClickerLoc.RedeemExchangeRate(rate), 55, n"Bold", this.m_colGray);
    infoText.SetHAlign(inkEHorizontalAlign.Center);
    infoText.Reparent(centerCol);

    let stagedText = this.MakeText(this.FmtRedeemStaged(this.m_stagedRedeemPoints, this.m_stagedRedeemPoints / rate), 80, n"Bold", this.m_colCyan);
    stagedText.SetHAlign(inkEHorizontalAlign.Center);
    stagedText.Reparent(centerCol);
    this.m_stagedText = stagedText;

    let incRow = new inkHorizontalPanel();
    incRow.SetHAlign(inkEHorizontalAlign.Center);
    incRow.SetChildMargin(new inkMargin(20.0, 0.0, 20.0, 0.0));
    incRow.SetFitToContent(true);
    incRow.Reparent(centerCol);

    let btn1k = new inkText(); btn1k.SetText("[ +" + IntToString(rate) + " ]"); this.StyleButton(btn1k, false); btn1k.AttachController(new CyberClickerMenuButtonController()); btn1k.RegisterToCallback(n"OnRelease", this, n"OnAddRedeem1k"); btn1k.Reparent(incRow);
    this.m_btn1k = btn1k;
    let btn10k = new inkText(); btn10k.SetText("[ +" + IntToString(rate * 10) + " ]"); this.StyleButton(btn10k, false); btn10k.AttachController(new CyberClickerMenuButtonController()); btn10k.RegisterToCallback(n"OnRelease", this, n"OnAddRedeem10k"); btn10k.Reparent(incRow);
    this.m_btn10k = btn10k;
    let btn100k = new inkText(); btn100k.SetText("[ +" + IntToString(rate * 100) + " ]"); this.StyleButton(btn100k, false); btn100k.AttachController(new CyberClickerMenuButtonController()); btn100k.RegisterToCallback(n"OnRelease", this, n"OnAddRedeem100k"); btn100k.Reparent(incRow);
    this.m_btn100k = btn100k;

    let actRow = new inkHorizontalPanel();
    actRow.SetHAlign(inkEHorizontalAlign.Center);
    actRow.SetChildMargin(new inkMargin(40.0, 0.0, 40.0, 0.0));
    actRow.SetFitToContent(true);
    actRow.SetMargin(new inkMargin(0.0, 40.0, 0.0, 0.0));
    actRow.Reparent(centerCol);

    let resetBtn = new inkText(); resetBtn.SetText(CyberClickerLoc.BtnReset()); this.StyleButton(resetBtn, false); resetBtn.AttachController(new CyberClickerMenuButtonController()); resetBtn.RegisterToCallback(n"OnRelease", this, n"OnResetRedeem"); resetBtn.Reparent(actRow);
    this.m_resetBtn = resetBtn;
    let confirmBtn = new inkText(); confirmBtn.SetText(CyberClickerLoc.BtnConfirm()); this.StyleButton(confirmBtn, false); confirmBtn.AttachController(new CyberClickerMenuButtonController()); confirmBtn.RegisterToCallback(n"OnRelease", this, n"OnConfirmRedeem"); confirmBtn.Reparent(actRow);
    this.m_confirmBtn = confirmBtn;

    let backBtn = new inkText(); backBtn.SetText(CyberClickerLoc.BtnBack()); this.StyleButton(backBtn, true); backBtn.SetMargin(new inkMargin(0.0, 30.0, 0.0, 0.0)); backBtn.RegisterToCallback(n"OnRelease", this, n"OnBackPressed"); backBtn.Reparent(centerCol);

    this.RefreshUI();
  }

  private func BuildShopMenuPage(canvas: ref<inkCanvas>, centerCol: ref<inkVerticalPanel>) -> Void {
    let menuContainer = new inkVerticalPanel();
    menuContainer.SetHAlign(inkEHorizontalAlign.Center);
    menuContainer.SetChildMargin(new inkMargin(0.0, 40.0, 0.0, 40.0));
    menuContainer.SetMargin(new inkMargin(0.0, 100.0, 0.0, 0.0));
    menuContainer.SetFitToContent(true);
    menuContainer.Reparent(centerCol);

    let genBtn = new inkText(); genBtn.SetText(CyberClickerLoc.BtnAutoGenerators()); this.StyleButton(genBtn, true);
    genBtn.RegisterToCallback(n"OnRelease", this, n"OnGoGeneratorsPressed"); genBtn.Reparent(menuContainer);

    let upgBtn = new inkText(); upgBtn.SetText(CyberClickerLoc.BtnSystemUpgrades()); this.StyleButton(upgBtn, true);
    upgBtn.RegisterToCallback(n"OnRelease", this, n"OnGoUpgradesPressed"); upgBtn.Reparent(menuContainer);

    let backBtn = new inkText(); backBtn.SetText(CyberClickerLoc.BtnBack()); this.StyleButton(backBtn, true);
    backBtn.SetAnchor(inkEAnchor.BottomCenter);
    backBtn.SetAnchorPoint(new Vector2(0.5, 1.0));
    backBtn.SetMargin(new inkMargin(0.0, 0.0, 0.0, 50.0));
    backBtn.RegisterToCallback(n"OnRelease", this, n"OnBackPressed"); backBtn.Reparent(canvas);
  }

  private func BuildGeneratorsPage(canvas: ref<inkCanvas>, centerCol: ref<inkVerticalPanel>, pts: Int32) -> Void {
    let t1b = this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0);
    let t2b = this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
    let t3b = this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
    let t4b = this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);

    let listContainer = new inkVerticalPanel();
    listContainer.SetHAlign(inkEHorizontalAlign.Center);
    listContainer.SetChildMargin(new inkMargin(0.0, 10.0, 0.0, 10.0));
    listContainer.SetMargin(new inkMargin(0.0, 50.0, 0.0, 0.0));
    listContainer.SetFitToContent(true);
    listContainer.Reparent(centerCol);

    let headerGen = new inkText(); headerGen.SetText(CyberClickerLoc.HeaderAutoGenerators()); this.StyleShopHeader(headerGen); headerGen.SetHAlign(inkEHorizontalAlign.Center); headerGen.Reparent(listContainer);

    let cT1b = this.CostBotT1(t1b);
    let btnT1b = new inkText(); btnT1b.SetText(this.FmtGenBotEntry(CyberClickerLoc.GenNameT1(), t1b, this.GetBotMilestoneMult(t1b), this.GetNextMilestoneStr(t1b), cT1b));
    this.StyleShopButton(btnT1b, pts >= cT1b); btnT1b.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT1b { btnT1b.RegisterToCallback(n"OnRelease", this, n"OnBuyT1Bot"); } btnT1b.Reparent(listContainer);

    let cT2b = this.CostBotT2(t2b);
    let btnT2b = new inkText(); btnT2b.SetText(this.FmtGenBotEntry(CyberClickerLoc.GenNameT2(), t2b, this.GetBotMilestoneMult(t2b), this.GetNextMilestoneStr(t2b), cT2b));
    this.StyleShopButton(btnT2b, pts >= cT2b); btnT2b.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT2b { btnT2b.RegisterToCallback(n"OnRelease", this, n"OnBuyT2Bot"); } btnT2b.Reparent(listContainer);

    let cT3b = this.CostBotT3(t3b);
    let btnT3b = new inkText(); btnT3b.SetText(this.FmtGenBotEntry(CyberClickerLoc.GenNameT3(), t3b, this.GetBotMilestoneMult(t3b), this.GetNextMilestoneStr(t3b), cT3b));
    this.StyleShopButton(btnT3b, pts >= cT3b); btnT3b.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT3b { btnT3b.RegisterToCallback(n"OnRelease", this, n"OnBuyT3Bot"); } btnT3b.Reparent(listContainer);

    let cT4b = this.CostBotT4(t4b);
    let btnT4b = new inkText(); btnT4b.SetText(this.FmtGenBotEntry(CyberClickerLoc.GenNameT4(), t4b, this.GetBotMilestoneMult(t4b), this.GetNextMilestoneStr(t4b), cT4b));
    this.StyleShopButton(btnT4b, pts >= cT4b); btnT4b.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT4b { btnT4b.RegisterToCallback(n"OnRelease", this, n"OnBuyT4Bot"); } btnT4b.Reparent(listContainer);

    let backBtn = new inkText(); backBtn.SetText(CyberClickerLoc.BtnBackToMenu()); this.StyleButton(backBtn, true);
    backBtn.SetAnchor(inkEAnchor.BottomCenter);
    backBtn.SetAnchorPoint(new Vector2(0.5, 1.0));
    backBtn.SetMargin(new inkMargin(0.0, 0.0, 0.0, 50.0));
    backBtn.RegisterToCallback(n"OnRelease", this, n"OnBackToShopPressed"); backBtn.Reparent(canvas);
  }

  private func BuildUpgradesPage(canvas: ref<inkCanvas>, centerCol: ref<inkVerticalPanel>, pts: Int32) -> Void {
    let listContainer = new inkVerticalPanel();
    listContainer.SetHAlign(inkEHorizontalAlign.Center);
    listContainer.SetChildMargin(new inkMargin(0.0, 10.0, 0.0, 10.0));
    listContainer.SetMargin(new inkMargin(0.0, 50.0, 0.0, 0.0));
    listContainer.SetFitToContent(true);
    listContainer.Reparent(centerCol);

    let headerClk = new inkText(); headerClk.SetText(CyberClickerLoc.HeaderSystemUpgrades()); this.StyleShopHeader(headerClk); headerClk.SetHAlign(inkEHorizontalAlign.Center); headerClk.Reparent(listContainer);

    let t1c = this.GetFactOrDefault(CyberClickerFacts.T1Clicks(), 0); let cT1c = this.CostClickT1(t1c);
    let btnT1c = new inkText(); btnT1c.SetText(this.FmtUpgClickEntry(CyberClickerLoc.UpgNameT1(), 1, t1c, cT1c));
    this.StyleShopButton(btnT1c, pts >= cT1c); btnT1c.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT1c { btnT1c.RegisterToCallback(n"OnRelease", this, n"OnBuyT1Click"); } btnT1c.Reparent(listContainer);

    let t2c = this.GetFactOrDefault(CyberClickerFacts.T2Clicks(), 0); let cT2c = this.CostClickT2(t2c);
    let btnT2c = new inkText(); btnT2c.SetText(this.FmtUpgClickEntry(CyberClickerLoc.UpgNameT2(), 5, t2c, cT2c));
    this.StyleShopButton(btnT2c, pts >= cT2c); btnT2c.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT2c { btnT2c.RegisterToCallback(n"OnRelease", this, n"OnBuyT2Click"); } btnT2c.Reparent(listContainer);

    let t3c = this.GetFactOrDefault(CyberClickerFacts.T3Clicks(), 0); let cT3c = this.CostClickT3(t3c);
    let btnT3c = new inkText(); btnT3c.SetText(this.FmtUpgClickEntry(CyberClickerLoc.UpgNameT3(), 25, t3c, cT3c));
    this.StyleShopButton(btnT3c, pts >= cT3c); btnT3c.SetHAlign(inkEHorizontalAlign.Center); if pts >= cT3c { btnT3c.RegisterToCallback(n"OnRelease", this, n"OnBuyT3Click"); } btnT3c.Reparent(listContainer);

    let capLvl = this.GetFactOrDefault(CyberClickerFacts.Capacity(), 0); let capCost = this.CostCapacity(capLvl);
    let capR = StrReplace(CyberClickerLoc.UpgCapEntry(), "{lvl}", IntToString(capLvl));
    let btnCap = new inkText(); btnCap.SetText(StrReplace(capR, "{cost}", IntToString(capCost)));
    this.StyleShopButton(btnCap, pts >= capCost); btnCap.SetHAlign(inkEHorizontalAlign.Center); if pts >= capCost { btnCap.RegisterToCallback(n"OnRelease", this, n"OnBuyCap"); } btnCap.Reparent(listContainer);

    let backBtn = new inkText(); backBtn.SetText(CyberClickerLoc.BtnBackToMenu()); this.StyleButton(backBtn, true);
    backBtn.SetAnchor(inkEAnchor.BottomCenter);
    backBtn.SetAnchorPoint(new Vector2(0.5, 1.0));
    backBtn.SetMargin(new inkMargin(0.0, 0.0, 0.0, 50.0));
    backBtn.RegisterToCallback(n"OnRelease", this, n"OnBackToShopPressed"); backBtn.Reparent(canvas);
  }

  // Main Handlers
  // ----------------------------

  public func PlayClickSfx(sound: CName) -> Void {
    let player: wref<PlayerPuppet> = GetPlayer(GetGameInstance());
    if !IsDefined(player) { return; }
    let evt: ref<AudioEvent> = new AudioEvent();
    evt.eventName = sound;
    player.QueueEvent(evt);
  }
  
  protected cb func OnClickPressed(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      evt.Consume();
      this.PlayClickSfx(n"q_sts_ep1_10_bill_press_button");
      this.ClearMessage();
      let ppc = this.GetTotalPPC();
      let pts = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.SetFact(CyberClickerFacts.Points(), this.ClampPoints(pts + ppc));
      let clicks = this.GetFactOrDefault(CyberClickerFacts.TotalClicks(), 0);
      this.SetFact(CyberClickerFacts.TotalClicks(), this.ClampPoints(clicks + 1));
      this.RefreshUI();
    }
    return false;
  }
  protected cb func OnGoShopPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_deviceLogicController.LoadPageByAddress(this.m_shopAddr); } return false; }
  protected cb func OnGoRedeemPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_stagedRedeemPoints = 0; this.m_deviceLogicController.LoadPageByAddress(this.m_redeemAddr); } return false; }
  protected cb func OnBackPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_stagedRedeemPoints = 0; this.m_deviceLogicController.LoadPageByAddress(this.m_mainAddr); } return false; }
  protected cb func OnGoGeneratorsPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_deviceLogicController.LoadPageByAddress(this.m_generatorsAddr); } return false; }
  protected cb func OnGoUpgradesPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_deviceLogicController.LoadPageByAddress(this.m_upgradesAddr); } return false; }
  protected cb func OnGoAchievementsPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_deviceLogicController.LoadPageByAddress(this.m_achievementsAddr); } return false; }
  protected cb func OnBackToShopPressed(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_onpress"); this.ClearMessage(); this.m_deviceLogicController.LoadPageByAddress(this.m_shopAddr); } return false; }

  // Shop Handlers
  protected cb func OnBuyT1Bot(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0); if this.TrySpendPoints(this.CostBotT1(lvl), CyberClickerLoc.GenNameT1()) { this.SetFact(CyberClickerFacts.T1Bots(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }
  protected cb func OnBuyT2Bot(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0); if this.TrySpendPoints(this.CostBotT2(lvl), CyberClickerLoc.GenNameT2()) { this.SetFact(CyberClickerFacts.T2Bots(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }
  protected cb func OnBuyT3Bot(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0); if this.TrySpendPoints(this.CostBotT3(lvl), CyberClickerLoc.GenNameT3()) { this.SetFact(CyberClickerFacts.T3Bots(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }
  protected cb func OnBuyT4Bot(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0); if this.TrySpendPoints(this.CostBotT4(lvl), CyberClickerLoc.GenNameT4()) { this.SetFact(CyberClickerFacts.T4Bots(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }

  protected cb func OnBuyT1Click(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T1Clicks(), 0); if this.TrySpendPoints(this.CostClickT1(lvl), CyberClickerLoc.UpgNameT1()) { this.SetFact(CyberClickerFacts.T1Clicks(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }
  protected cb func OnBuyT2Click(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T2Clicks(), 0); if this.TrySpendPoints(this.CostClickT2(lvl), CyberClickerLoc.UpgNameT2()) { this.SetFact(CyberClickerFacts.T2Clicks(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }
  protected cb func OnBuyT3Click(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.T3Clicks(), 0); if this.TrySpendPoints(this.CostClickT3(lvl), CyberClickerLoc.UpgNameT3()) { this.SetFact(CyberClickerFacts.T3Clicks(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }

  protected cb func OnBuyCap(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); let lvl = this.GetFactOrDefault(CyberClickerFacts.Capacity(), 0); if this.TrySpendPoints(this.CostCapacity(lvl), CyberClickerLoc.UpgNameCap()) { this.SetFact(CyberClickerFacts.Capacity(), lvl + 1); this.PlayClickSfx(n"ui_menu_perk_buy_master"); } this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }

  // Redeem Handlers
  private func AddStagedRedeem(amount: Int32) -> Void {
    let rate: Int32 = this.GetRedeemRate();
    let pts: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    let space: Int32 = pts - this.m_stagedRedeemPoints;
    if space < rate { return; }
    let safeAmount: Int32 = amount; if safeAmount > space { safeAmount = (space / rate) * rate; }
    this.m_stagedRedeemPoints += safeAmount;
    this.PlayClickSfx(n"ui_menu_value_up");
    this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr);
  }
  protected cb func OnAddRedeem1k(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.AddStagedRedeem(this.GetRedeemRate()); } return false; }
  protected cb func OnAddRedeem10k(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.AddStagedRedeem(this.GetRedeemRate() * 10); } return false; }
  protected cb func OnAddRedeem100k(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.AddStagedRedeem(this.GetRedeemRate() * 100); } return false; }
  protected cb func OnResetRedeem(evt: ref<inkPointerEvent>) -> Bool { if evt.IsAction(n"click") { evt.Consume(); this.PlayClickSfx(n"ui_menu_value_down"); this.m_stagedRedeemPoints = 0; this.m_lastMsg = s""; this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr); } return false; }
  protected cb func OnConfirmRedeem(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      evt.Consume();
      this.PlayClickSfx(n"ui_menu_onpress");
      if this.m_stagedRedeemPoints > 0 {
        let pts: Int32 = this.GetFactOrDefault(CyberClickerFacts.Points(), 0);
        if pts >= this.m_stagedRedeemPoints {
          this.SetFact(CyberClickerFacts.Points(), this.ClampPoints(pts - this.m_stagedRedeemPoints));
          let eddies: Int32 = this.m_stagedRedeemPoints / this.GetRedeemRate();
          this.GivePlayerMoney(eddies);
          let redeems = this.GetFactOrDefault(CyberClickerFacts.TotalRedeems(), 0);
          this.SetFact(CyberClickerFacts.TotalRedeems(), redeems + 1);
          this.ShowMessage(StrReplace(CyberClickerLoc.RedeemTransferred(), "{eddies}", IntToString(eddies)), true);
          this.m_stagedRedeemPoints = 0;
        } else { this.ShowMessage(CyberClickerLoc.RedeemErrorNotEnough(), false); }
      }
      this.m_deviceLogicController.LoadPageByAddress(this.m_currentAddr);
    }
    return false;
  }
}

@addField(BrowserGameController)
private let m_cyberClickerSiteListener: ref<CyberClickerSiteListener>;

@wrapMethod(BrowserGameController)
protected cb func OnInitialize() -> Bool {
  let result = wrappedMethod();
  this.m_cyberClickerSiteListener = new CyberClickerSiteListener();
  this.m_cyberClickerSiteListener.Init(this);
  return result;
}

@wrapMethod(BrowserGameController)
protected cb func OnUninitialize() -> Bool {
  let result = wrappedMethod();
  if IsDefined(this.m_cyberClickerSiteListener) {
    this.m_cyberClickerSiteListener.Uninit();
    this.m_cyberClickerSiteListener = null;
  }
  return result;
}