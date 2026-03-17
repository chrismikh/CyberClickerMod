module CyberClicker

// Shared fact CName constants for the Cyber Clicker mod.
// All game state and achievement facts are defined here once — no more "KEEP IN SYNC".
public abstract class CyberClickerFacts {
  // Economy
  public static func Points() -> CName { return n"CyberClicker_Points"; }
  public static func Capacity() -> CName { return n"CyberClicker_CapacityLevel"; }

  // Generators (Bots)
  public static func T1Bots() -> CName { return n"CyberClicker_T1_Bots"; }
  public static func T2Bots() -> CName { return n"CyberClicker_T2_Bots"; }
  public static func T3Bots() -> CName { return n"CyberClicker_T3_Bots"; }
  public static func T4Bots() -> CName { return n"CyberClicker_T4_Bots"; }

  // Click Upgrades
  public static func T1Clicks() -> CName { return n"CyberClicker_T1_Clicks"; }
  public static func T2Clicks() -> CName { return n"CyberClicker_T2_Clicks"; }
  public static func T3Clicks() -> CName { return n"CyberClicker_T3_Clicks"; }

  // Tracking
  public static func LastGameTime() -> CName { return n"CyberClicker_LastGameTime"; }
  public static func TotalClicks() -> CName { return n"CyberClicker_TotalClicks"; }
  public static func TotalRedeems() -> CName { return n"CyberClicker_TotalRedeems"; }

  // Achievements
  public static func AchFirstByte() -> CName { return n"CyberClicker_Ach_FirstByte"; }
  public static func AchDataMiner() -> CName { return n"CyberClicker_Ach_DataMiner"; }
  public static func AchClickManiac() -> CName { return n"CyberClicker_Ach_ClickManiac"; }
  public static func AchLegendRunner() -> CName { return n"CyberClicker_Ach_LegendRunner"; }
  public static func AchKiddieSquad() -> CName { return n"CyberClicker_Ach_KiddieSquad"; }
  public static func AchBotArmy() -> CName { return n"CyberClicker_Ach_BotArmy"; }
  public static func AchBotEmpire() -> CName { return n"CyberClicker_Ach_BotEmpire"; }
  public static func AchDaemonWhisp() -> CName { return n"CyberClicker_Ach_DaemonWhisp"; }
  public static func AchBeyondWall() -> CName { return n"CyberClicker_Ach_BeyondWall"; }
  public static func AchFirstPayday() -> CName { return n"CyberClicker_Ach_FirstPayday"; }
  public static func AchOverclocker() -> CName { return n"CyberClicker_Ach_Overclocker"; }
  public static func AchMemoryExp() -> CName { return n"CyberClicker_Ach_MemoryExp"; }
  public static func AchSubnetLord() -> CName { return n"CyberClicker_Ach_SubnetLord"; }
  public static func AchQuickHack() -> CName { return n"CyberClicker_Ach_QuickHack"; }
  public static func AchDataHoarder() -> CName { return n"CyberClicker_Ach_DataHoarder"; }
  public static func AchNetProfit() -> CName { return n"CyberClicker_Ach_NetProfit"; }
  public static func AchMassProduce() -> CName { return n"CyberClicker_Ach_MassProduce"; }
  public static func AchSpecterNet() -> CName { return n"CyberClicker_Ach_SpecterNet"; }
  public static func AchMegaClicker() -> CName { return n"CyberClicker_Ach_MegaClicker"; }
  public static func AchNeuralMaster() -> CName { return n"CyberClicker_Ach_NeuralMaster"; }
  public static func AchSysadmin() -> CName { return n"CyberClicker_Ach_Sysadmin"; }
  public static func AchSilverhand() -> CName { return n"CyberClicker_Ach_Silverhand"; }
}
