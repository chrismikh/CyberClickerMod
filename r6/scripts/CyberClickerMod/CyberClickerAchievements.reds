module CyberClicker

import BrowserExtension.DataStructures.*
import BrowserExtension.Classes.*
import BrowserExtension.System.*

// ------------------------------------------------------------
// Achievements — standalone class split from CyberClickerWeb.reds
// Holds a reference to the site listener to access game state.
// ------------------------------------------------------------
public class CyberClickerAchievements extends IScriptable {
  private let m_site: wref<CyberClickerSiteListener>;

  public func Init(site: ref<CyberClickerSiteListener>) -> Void {
    this.m_site = site;
  }

  public func GetUnclaimedAchCount() -> Int32 {
    let count: Int32 = 0;
    let totalClicks = this.m_site.GetFactOrDefault(CyberClickerFacts.TotalClicks(), 0);
    let totalRedeems = this.m_site.GetFactOrDefault(CyberClickerFacts.TotalRedeems(), 0);
    let totalBots = this.m_site.GetTotalBots();
    let ppc = this.m_site.GetTotalPPC();
    let capLvl = this.m_site.GetFactOrDefault(CyberClickerFacts.Capacity(), 0);
    let t1b = this.m_site.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0);
    let t2b = this.m_site.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
    let t3b = this.m_site.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
    let t4b = this.m_site.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
    let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    let autoPerMin = this.m_site.GetTotalAutoPerMin();
    if totalClicks >= 1     && this.m_site.GetFactOrDefault(CyberClickerFacts.AchFirstByte(), 0)    < 1 { count += 1; }
    if totalClicks >= 100    && this.m_site.GetFactOrDefault(CyberClickerFacts.AchDataMiner(), 0)    < 1 { count += 1; }
    if totalClicks >= 1000   && this.m_site.GetFactOrDefault(CyberClickerFacts.AchClickManiac(), 0)  < 1 { count += 1; }
    if totalClicks >= 10000  && this.m_site.GetFactOrDefault(CyberClickerFacts.AchLegendRunner(), 0) < 1 { count += 1; }
    if t1b >= 10             && this.m_site.GetFactOrDefault(CyberClickerFacts.AchKiddieSquad(), 0)  < 1 { count += 1; }
    if totalBots >= 50       && this.m_site.GetFactOrDefault(CyberClickerFacts.AchBotArmy(), 0)      < 1 { count += 1; }
    if totalBots >= 100      && this.m_site.GetFactOrDefault(CyberClickerFacts.AchBotEmpire(), 0)    < 1 { count += 1; }
    if t2b >= 25             && this.m_site.GetFactOrDefault(CyberClickerFacts.AchDaemonWhisp(), 0)  < 1 { count += 1; }
    if t4b >= 5              && this.m_site.GetFactOrDefault(CyberClickerFacts.AchBeyondWall(), 0)   < 1 { count += 1; }
    if totalRedeems >= 1     && this.m_site.GetFactOrDefault(CyberClickerFacts.AchFirstPayday(), 0)  < 1 { count += 1; }
    if ppc >= 50             && this.m_site.GetFactOrDefault(CyberClickerFacts.AchOverclocker(), 0)  < 1 { count += 1; }
    if capLvl >= 5           && this.m_site.GetFactOrDefault(CyberClickerFacts.AchMemoryExp(), 0)    < 1 { count += 1; }
    if totalBots >= 200      && this.m_site.GetFactOrDefault(CyberClickerFacts.AchSubnetLord(), 0)   < 1 { count += 1; }
    if ppc >= 100            && this.m_site.GetFactOrDefault(CyberClickerFacts.AchQuickHack(), 0)    < 1 { count += 1; }
    if pts >= 1000000        && this.m_site.GetFactOrDefault(CyberClickerFacts.AchDataHoarder(), 0)  < 1 { count += 1; }
    if totalRedeems >= 10    && this.m_site.GetFactOrDefault(CyberClickerFacts.AchNetProfit(), 0)    < 1 { count += 1; }
    if t3b >= 10             && this.m_site.GetFactOrDefault(CyberClickerFacts.AchMassProduce(), 0)  < 1 { count += 1; }
    if t4b >= 25             && this.m_site.GetFactOrDefault(CyberClickerFacts.AchSpecterNet(), 0)   < 1 { count += 1; }
    if totalClicks >= 50000  && this.m_site.GetFactOrDefault(CyberClickerFacts.AchMegaClicker(), 0)  < 1 { count += 1; }
    if ppc >= 250            && this.m_site.GetFactOrDefault(CyberClickerFacts.AchNeuralMaster(), 0) < 1 { count += 1; }
    if capLvl >= 10          && this.m_site.GetFactOrDefault(CyberClickerFacts.AchSysadmin(), 0)     < 1 { count += 1; }
    if autoPerMin >= 10000   && this.m_site.GetFactOrDefault(CyberClickerFacts.AchSilverhand(), 0)   < 1 { count += 1; }
    return count;
  }

  private func FmtAchRow(template: String, title: String, progress: String, reward: String) -> String {
    let r1 = StrReplace(template, "{title}", title);
    let r2 = StrReplace(r1, "{progress}", progress);
    return StrReplace(r2, "{reward}", reward);
  }

  private func FmtAchProg(template: String, n: Int32) -> String {
    return StrReplace(template, "{n}", IntToString(n));
  }

  private func BuildAchRow(parent: ref<inkCompoundWidget>, claimed: Bool, unlocked: Bool, title: String, progress: String, reward: String) -> ref<inkWidget> {
    let row = new inkHorizontalPanel();
    row.SetHAlign(inkEHorizontalAlign.Center);
    row.SetChildMargin(new inkMargin(8.0, 0.0, 8.0, 0.0));
    row.SetFitToContent(true);
    row.Reparent(parent);

    if !unlocked && !claimed {
      let icon = new inkImage();
      icon.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas");
      icon.SetTexturePart(n"ico_lock");
      icon.SetSize(new Vector2(36.0, 36.0));
      icon.SetTintColor(this.m_site.ColDarkGray());
      icon.SetVAlign(inkEVerticalAlign.Center);
      icon.SetFitToContent(false);
      icon.Reparent(row);
    }

    let text = new inkText();
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Semi-Bold");
    text.SetFontSize(48);
    text.SetFitToContent(true);
    text.SetHAlign(inkEHorizontalAlign.Left);

    if claimed {
      text.SetText(this.FmtAchRow(CyberClickerLoc.AchRowClaimed(), title, progress, reward));
      text.SetTintColor(this.m_site.ColGreen());
    } else if unlocked {
      text.SetText(this.FmtAchRow(CyberClickerLoc.AchRowClaimable(), title, progress, reward));
      text.SetTintColor(this.m_site.ColCyan());
      text.SetInteractive(true);
      text.AttachController(new CyberClickerMenuButtonController());
    } else {
      text.SetText(this.FmtAchRow(CyberClickerLoc.AchRowLocked(), title, progress, reward));
      text.SetTintColor(this.m_site.ColDarkGray());
    }
    text.Reparent(row);

    return text;
  }

  public func BuildAchievementsPage(canvas: ref<inkCanvas>) -> Void {
    let totalClicks = this.m_site.GetFactOrDefault(CyberClickerFacts.TotalClicks(), 0);
    let totalRedeems = this.m_site.GetFactOrDefault(CyberClickerFacts.TotalRedeems(), 0);
    let totalBots = this.m_site.GetTotalBots();
    let achPpc = this.m_site.GetTotalPPC();
    let achCapLvl = this.m_site.GetFactOrDefault(CyberClickerFacts.Capacity(), 0);
    let achT1b = this.m_site.GetFactOrDefault(CyberClickerFacts.T1Bots(), 0);
    let achT2b = this.m_site.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
    let achT3b = this.m_site.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
    let achT4b = this.m_site.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
    let achAutoPerMin = this.m_site.GetTotalAutoPerMin();

    // Top section: header + message
    let topBar = new inkVerticalPanel();
    topBar.SetAnchor(inkEAnchor.TopCenter);
    topBar.SetAnchorPoint(new Vector2(0.5, 0.0));
    topBar.SetMargin(new inkMargin(0.0, 20.0, 0.0, 0.0));
    topBar.SetFitToContent(true);
    topBar.Reparent(canvas);

    let achHeader = new inkText();
    achHeader.SetText(CyberClickerLoc.AchPageHeader());
    achHeader.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    achHeader.SetFontStyle(n"Bold");
    achHeader.SetFontSize(72);
    achHeader.SetTintColor(this.m_site.ColHeader());
    achHeader.SetHAlign(inkEHorizontalAlign.Center);
    achHeader.SetFitToContent(true);
    achHeader.Reparent(topBar);

    let msgAch = new inkText();
    if StrLen(this.m_site.GetLastMsg()) > 0 { msgAch.SetText(this.m_site.GetLastMsg()); } else { msgAch.SetText(" "); }
    msgAch.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    msgAch.SetFontStyle(n"Regular");
    msgAch.SetFontSize(38);
    msgAch.SetHAlign(inkEHorizontalAlign.Center);
    msgAch.SetFitToContent(true);
    msgAch.SetTintColor(this.m_site.IsLastMsgOk() ? this.m_site.ColGreen() : this.m_site.ColRed());
    msgAch.Reparent(topBar);
    this.m_site.SetMsgTextWidget(msgAch);

    // Two-column layout
    let colRow = new inkHorizontalPanel();
    colRow.SetAnchor(inkEAnchor.TopCenter);
    colRow.SetAnchorPoint(new Vector2(0.5, 0.0));
    colRow.SetMargin(new inkMargin(0.0, 160.0, 0.0, 0.0));
    colRow.SetChildMargin(new inkMargin(30.0, 0.0, 30.0, 0.0));
    colRow.SetFitToContent(true);
    colRow.Reparent(canvas);

    let leftCol = new inkVerticalPanel();
    leftCol.SetChildMargin(new inkMargin(0.0, 2.0, 0.0, 2.0));
    leftCol.SetFitToContent(true);
    leftCol.Reparent(colRow);

    let rightCol = new inkVerticalPanel();
    rightCol.SetChildMargin(new inkMargin(0.0, 2.0, 0.0, 2.0));
    rightCol.SetFitToContent(true);
    rightCol.Reparent(colRow);

    // LEFT COLUMN (1-11)
    let a1c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchFirstByte(), 0) >= 1;
    let a1u = totalClicks >= 1;
    let w1 = this.BuildAchRow(leftCol, a1c, a1u, CyberClickerLoc.AchName1(), this.FmtAchProg(CyberClickerLoc.AchProg1(), totalClicks), CyberClickerLoc.AchReward1());
    if !a1c && a1u { w1.RegisterToCallback(n"OnRelease", this, n"OnClaimAch1"); }

    let a2c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchDataMiner(), 0) >= 1;
    let a2u = totalClicks >= 100;
    let w2 = this.BuildAchRow(leftCol, a2c, a2u, CyberClickerLoc.AchName2(), this.FmtAchProg(CyberClickerLoc.AchProg2(), totalClicks), CyberClickerLoc.AchReward2());
    if !a2c && a2u { w2.RegisterToCallback(n"OnRelease", this, n"OnClaimAch2"); }

    let a3c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchClickManiac(), 0) >= 1;
    let a3u = totalClicks >= 1000;
    let w3 = this.BuildAchRow(leftCol, a3c, a3u, CyberClickerLoc.AchName3(), this.FmtAchProg(CyberClickerLoc.AchProg3(), totalClicks), CyberClickerLoc.AchReward3());
    if !a3c && a3u { w3.RegisterToCallback(n"OnRelease", this, n"OnClaimAch3"); }

    let a4c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchLegendRunner(), 0) >= 1;
    let a4u = totalClicks >= 10000;
    let w4 = this.BuildAchRow(leftCol, a4c, a4u, CyberClickerLoc.AchName4(), this.FmtAchProg(CyberClickerLoc.AchProg4(), totalClicks), CyberClickerLoc.AchReward4());
    if !a4c && a4u { w4.RegisterToCallback(n"OnRelease", this, n"OnClaimAch4"); }

    let a5c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchKiddieSquad(), 0) >= 1;
    let a5u = achT1b >= 10;
    let w5 = this.BuildAchRow(leftCol, a5c, a5u, CyberClickerLoc.AchName5(), this.FmtAchProg(CyberClickerLoc.AchProg5(), achT1b), CyberClickerLoc.AchReward5());
    if !a5c && a5u { w5.RegisterToCallback(n"OnRelease", this, n"OnClaimAch5"); }

    let a6c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchBotArmy(), 0) >= 1;
    let a6u = totalBots >= 50;
    let w6 = this.BuildAchRow(leftCol, a6c, a6u, CyberClickerLoc.AchName6(), this.FmtAchProg(CyberClickerLoc.AchProg6(), totalBots), CyberClickerLoc.AchReward6());
    if !a6c && a6u { w6.RegisterToCallback(n"OnRelease", this, n"OnClaimAch6"); }

    let a7c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchBotEmpire(), 0) >= 1;
    let a7u = totalBots >= 100;
    let w7 = this.BuildAchRow(leftCol, a7c, a7u, CyberClickerLoc.AchName7(), this.FmtAchProg(CyberClickerLoc.AchProg7(), totalBots), CyberClickerLoc.AchReward7());
    if !a7c && a7u { w7.RegisterToCallback(n"OnRelease", this, n"OnClaimAch7"); }

    let a8c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchDaemonWhisp(), 0) >= 1;
    let a8u = achT2b >= 25;
    let w8 = this.BuildAchRow(leftCol, a8c, a8u, CyberClickerLoc.AchName8(), this.FmtAchProg(CyberClickerLoc.AchProg8(), achT2b), CyberClickerLoc.AchReward8());
    if !a8c && a8u { w8.RegisterToCallback(n"OnRelease", this, n"OnClaimAch8"); }

    let a9c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchBeyondWall(), 0) >= 1;
    let a9u = achT4b >= 5;
    let w9 = this.BuildAchRow(leftCol, a9c, a9u, CyberClickerLoc.AchName9(), this.FmtAchProg(CyberClickerLoc.AchProg9(), achT4b), CyberClickerLoc.AchReward9());
    if !a9c && a9u { w9.RegisterToCallback(n"OnRelease", this, n"OnClaimAch9"); }

    let a10c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchFirstPayday(), 0) >= 1;
    let a10u = totalRedeems >= 1;
    let w10 = this.BuildAchRow(leftCol, a10c, a10u, CyberClickerLoc.AchName10(), this.FmtAchProg(CyberClickerLoc.AchProg10(), totalRedeems), CyberClickerLoc.AchReward10());
    if !a10c && a10u { w10.RegisterToCallback(n"OnRelease", this, n"OnClaimAch10"); }

    let a11c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchOverclocker(), 0) >= 1;
    let a11u = achPpc >= 50;
    let w11 = this.BuildAchRow(leftCol, a11c, a11u, CyberClickerLoc.AchName11(), this.FmtAchProg(CyberClickerLoc.AchProg11(), achPpc), CyberClickerLoc.AchReward11());
    if !a11c && a11u { w11.RegisterToCallback(n"OnRelease", this, n"OnClaimAch11"); }

    // RIGHT COLUMN (12-22)
    let a12c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchMemoryExp(), 0) >= 1;
    let a12u = achCapLvl >= 5;
    let w12 = this.BuildAchRow(rightCol, a12c, a12u, CyberClickerLoc.AchName12(), this.FmtAchProg(CyberClickerLoc.AchProg12(), achCapLvl), CyberClickerLoc.AchReward12());
    if !a12c && a12u { w12.RegisterToCallback(n"OnRelease", this, n"OnClaimAch12"); }

    let a13c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchSubnetLord(), 0) >= 1;
    let a13u = totalBots >= 200;
    let w13 = this.BuildAchRow(rightCol, a13c, a13u, CyberClickerLoc.AchName13(), this.FmtAchProg(CyberClickerLoc.AchProg13(), totalBots), CyberClickerLoc.AchReward13());
    if !a13c && a13u { w13.RegisterToCallback(n"OnRelease", this, n"OnClaimAch13"); }

    let a14c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchQuickHack(), 0) >= 1;
    let a14u = achPpc >= 100;
    let w14 = this.BuildAchRow(rightCol, a14c, a14u, CyberClickerLoc.AchName14(), this.FmtAchProg(CyberClickerLoc.AchProg14(), achPpc), CyberClickerLoc.AchReward14());
    if !a14c && a14u { w14.RegisterToCallback(n"OnRelease", this, n"OnClaimAch14"); }

    let a15c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchDataHoarder(), 0) >= 1;
    let achPts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
    let a15u = achPts >= 1000000;
    let w15 = this.BuildAchRow(rightCol, a15c, a15u, CyberClickerLoc.AchName15(), this.FmtAchProg(CyberClickerLoc.AchProg15(), achPts), CyberClickerLoc.AchReward15());
    if !a15c && a15u { w15.RegisterToCallback(n"OnRelease", this, n"OnClaimAch15"); }

    let a16c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchNetProfit(), 0) >= 1;
    let a16u = totalRedeems >= 10;
    let w16 = this.BuildAchRow(rightCol, a16c, a16u, CyberClickerLoc.AchName16(), this.FmtAchProg(CyberClickerLoc.AchProg16(), totalRedeems), CyberClickerLoc.AchReward16());
    if !a16c && a16u { w16.RegisterToCallback(n"OnRelease", this, n"OnClaimAch16"); }

    let a17c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchMassProduce(), 0) >= 1;
    let a17u = achT3b >= 10;
    let w17 = this.BuildAchRow(rightCol, a17c, a17u, CyberClickerLoc.AchName17(), this.FmtAchProg(CyberClickerLoc.AchProg17(), achT3b), CyberClickerLoc.AchReward17());
    if !a17c && a17u { w17.RegisterToCallback(n"OnRelease", this, n"OnClaimAch17"); }

    let a18c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchSpecterNet(), 0) >= 1;
    let a18u = achT4b >= 25;
    let w18 = this.BuildAchRow(rightCol, a18c, a18u, CyberClickerLoc.AchName18(), this.FmtAchProg(CyberClickerLoc.AchProg18(), achT4b), CyberClickerLoc.AchReward18());
    if !a18c && a18u { w18.RegisterToCallback(n"OnRelease", this, n"OnClaimAch18"); }

    let a19c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchMegaClicker(), 0) >= 1;
    let a19u = totalClicks >= 50000;
    let w19 = this.BuildAchRow(rightCol, a19c, a19u, CyberClickerLoc.AchName19(), this.FmtAchProg(CyberClickerLoc.AchProg19(), totalClicks), CyberClickerLoc.AchReward19());
    if !a19c && a19u { w19.RegisterToCallback(n"OnRelease", this, n"OnClaimAch19"); }

    let a20c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchNeuralMaster(), 0) >= 1;
    let a20u = achPpc >= 250;
    let w20 = this.BuildAchRow(rightCol, a20c, a20u, CyberClickerLoc.AchName20(), this.FmtAchProg(CyberClickerLoc.AchProg20(), achPpc), CyberClickerLoc.AchReward20());
    if !a20c && a20u { w20.RegisterToCallback(n"OnRelease", this, n"OnClaimAch20"); }

    let a21c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchSysadmin(), 0) >= 1;
    let a21u = achCapLvl >= 10;
    let w21 = this.BuildAchRow(rightCol, a21c, a21u, CyberClickerLoc.AchName21(), this.FmtAchProg(CyberClickerLoc.AchProg21(), achCapLvl), CyberClickerLoc.AchReward21());
    if !a21c && a21u { w21.RegisterToCallback(n"OnRelease", this, n"OnClaimAch21"); }

    let a22c = this.m_site.GetFactOrDefault(CyberClickerFacts.AchSilverhand(), 0) >= 1;
    let a22u = achAutoPerMin >= 10000;
    let w22 = this.BuildAchRow(rightCol, a22c, a22u, CyberClickerLoc.AchName22(), this.FmtAchProg(CyberClickerLoc.AchProg22(), achAutoPerMin), CyberClickerLoc.AchReward22());
    if !a22c && a22u { w22.RegisterToCallback(n"OnRelease", this, n"OnClaimAch22"); }

    let backBtn = new inkText();
    backBtn.SetText(CyberClickerLoc.BtnBack());
    this.m_site.StyleButton(backBtn, true);
    backBtn.SetAnchor(inkEAnchor.BottomCenter);
    backBtn.SetAnchorPoint(new Vector2(0.5, 1.0));
    backBtn.SetMargin(new inkMargin(0.0, 0.0, 0.0, 50.0));
    backBtn.RegisterToCallback(n"OnRelease", this.m_site, n"OnBackPressed");
    backBtn.Reparent(canvas);
  }

  // --- Achievement Claim Handlers ---

  private func ClaimAchReward(achFact: CName) -> Void {
    this.m_site.SetFact(achFact, 1);
    this.m_site.PlayClickSfx(n"ui_menu_perk_buy_master");
    this.m_site.ReloadCurrentPage();
  }

  protected cb func OnClaimAch1(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 200));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg1(), true);
      this.ClaimAchReward(CyberClickerFacts.AchFirstByte());
    } return false;
  }

  protected cb func OnClaimAch2(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 1000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg2(), true);
      this.ClaimAchReward(CyberClickerFacts.AchDataMiner());
    } return false;
  }

  protected cb func OnClaimAch3(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 5000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg3(), true);
      this.ClaimAchReward(CyberClickerFacts.AchClickManiac());
    } return false;
  }

  protected cb func OnClaimAch4(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 25000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg4(), true);
      this.ClaimAchReward(CyberClickerFacts.AchLegendRunner());
    } return false;
  }

  protected cb func OnClaimAch5(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let lvl = this.m_site.GetFactOrDefault(CyberClickerFacts.T2Bots(), 0);
      this.m_site.SetFact(CyberClickerFacts.T2Bots(), lvl + 1);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg5(), true);
      this.ClaimAchReward(CyberClickerFacts.AchKiddieSquad());
    } return false;
  }

  protected cb func OnClaimAch6(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 15000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg6(), true);
      this.ClaimAchReward(CyberClickerFacts.AchBotArmy());
    } return false;
  }

  protected cb func OnClaimAch7(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let lvl = this.m_site.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
      this.m_site.SetFact(CyberClickerFacts.T4Bots(), lvl + 1);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg7(), true);
      this.ClaimAchReward(CyberClickerFacts.AchBotEmpire());
    } return false;
  }

  protected cb func OnClaimAch8(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let lvl = this.m_site.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
      this.m_site.SetFact(CyberClickerFacts.T3Bots(), lvl + 2);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg8(), true);
      this.ClaimAchReward(CyberClickerFacts.AchDaemonWhisp());
    } return false;
  }

  protected cb func OnClaimAch9(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 50000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg9(), true);
      this.ClaimAchReward(CyberClickerFacts.AchBeyondWall());
    } return false;
  }

  protected cb func OnClaimAch10(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 3000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg10(), true);
      this.ClaimAchReward(CyberClickerFacts.AchFirstPayday());
    } return false;
  }

  protected cb func OnClaimAch11(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 10000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg11(), true);
      this.ClaimAchReward(CyberClickerFacts.AchOverclocker());
    } return false;
  }

  protected cb func OnClaimAch12(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 35000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg12(), true);
      this.ClaimAchReward(CyberClickerFacts.AchMemoryExp());
    } return false;
  }

  protected cb func OnClaimAch13(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 150000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg13(), true);
      this.ClaimAchReward(CyberClickerFacts.AchSubnetLord());
    } return false;
  }

  protected cb func OnClaimAch14(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let lvl = this.m_site.GetFactOrDefault(CyberClickerFacts.T3Bots(), 0);
      this.m_site.SetFact(CyberClickerFacts.T3Bots(), lvl + 2);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg14(), true);
      this.ClaimAchReward(CyberClickerFacts.AchQuickHack());
    } return false;
  }

  protected cb func OnClaimAch15(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      this.m_site.GivePlayerMoney(5000);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg15(), true);
      this.ClaimAchReward(CyberClickerFacts.AchDataHoarder());
    } return false;
  }

  protected cb func OnClaimAch16(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 50000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg16(), true);
      this.ClaimAchReward(CyberClickerFacts.AchNetProfit());
    } return false;
  }

  protected cb func OnClaimAch17(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let lvl = this.m_site.GetFactOrDefault(CyberClickerFacts.T4Bots(), 0);
      this.m_site.SetFact(CyberClickerFacts.T4Bots(), lvl + 1);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg17(), true);
      this.ClaimAchReward(CyberClickerFacts.AchMassProduce());
    } return false;
  }

  protected cb func OnClaimAch18(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 300000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg18(), true);
      this.ClaimAchReward(CyberClickerFacts.AchSpecterNet());
    } return false;
  }

  protected cb func OnClaimAch19(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 300000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg19(), true);
      this.ClaimAchReward(CyberClickerFacts.AchMegaClicker());
    } return false;
  }

  protected cb func OnClaimAch20(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      this.m_site.GivePlayerMoney(10000);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg20(), true);
      this.ClaimAchReward(CyberClickerFacts.AchNeuralMaster());
    } return false;
  }

  protected cb func OnClaimAch21(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      let pts = this.m_site.GetFactOrDefault(CyberClickerFacts.Points(), 0);
      this.m_site.SetFact(CyberClickerFacts.Points(), this.m_site.ClampPoints(pts + 100000));
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg21(), true);
      this.ClaimAchReward(CyberClickerFacts.AchSysadmin());
    } return false;
  }

  protected cb func OnClaimAch22(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") { evt.Consume();
      this.m_site.GivePlayerMoney(15000);
      this.m_site.ShowMessage(CyberClickerLoc.AchMsg22(), true);
      this.ClaimAchReward(CyberClickerFacts.AchSilverhand());
    } return false;
  }
}
