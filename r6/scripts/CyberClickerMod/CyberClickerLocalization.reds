module CyberClicker

// CyberClickerLocalization.reds — Localization file for Cyber Clicker mod
// ----
// HOW TO TRANSLATE:
//   1. Edit ONLY the text inside the quotes on each return line.
//   2. Placeholders like {n}, {cost}, {amount} will be filled
//      in by the game — you may move them freely in the text.
//   3. Do NOT rename functions or remove placeholders entirely.
//
// Example:
//   English:  "Not enough data. Need {cost}."
//   Spanish:  "No hay suficientes datos. Necesitas {cost}."

public abstract class CyberClickerLoc {

  // General
  public static func SiteShortName() -> String { return "Cyber Clicker"; }
  public static func PageTitleMain() -> String { return "CYBER CLICKER"; }
  public static func DataSuffix() -> String { return " DATA"; }

  // Stats Panel (left column on main page)
  public static func StatsHeader() -> String { return "NETWORK STATS"; }

  public static func StatsBlock() -> String {
    return s"Power / Click: {ppc}\n\nScript Kiddies: {t1b} (+{t1p}/m)\nNetrunner Daemons: {t2b} (+{t2p}/m)\nAI Sub-Routines: {t3b} (+{t3p}/m)\nBlackwall Specters: {t4b} (+{t4p}/m)\n\nTotal Auto: {auto} / IN-GAME MIN\n\nMemory Cap: {cap}h (In-Game)";
  }

  // Navigation Buttons
  public static func BtnAchievements() -> String { return "[ ACHIEVEMENTS ]"; }
  public static func BtnAchievementsWithCount() -> String { return "[ [{n}] ACHIEVEMENTS ]"; }
  public static func BtnSystemUpgrades() -> String { return "[ SYSTEM UPGRADES ]"; }
  public static func BtnRedeemYourData() -> String { return "[ REDEEM YOUR DATA ]"; }
  public static func BtnAutoGenerators() -> String { return "[ AUTO GENERATORS ]"; }
  public static func BtnBack() -> String { return "[ BACK ]"; }
  public static func BtnBackToMenu() -> String { return "[ BACK TO MENU ]"; }
  public static func BtnReset() -> String { return "[ RESET ]"; }
  public static func BtnConfirm() -> String { return "[ CONFIRM ]"; }
  public static func BtnAdd1K() -> String { return "[ +1K ]"; }
  public static func BtnAdd10K() -> String { return "[ +10K ]"; }
  public static func BtnAdd100K() -> String { return "[ +100K ]"; }

  // Redeem Page
  public static func RedeemExchangeRate(rate: Int32) -> String { return "EXCHANGE RATE: " + IntToString(rate) + " DATA = 1 €$"; }
  public static func RedeemStaged() -> String { return "STAGED: {points} DATA  ->  {eddies} €$"; }
  public static func RedeemTransferred() -> String { return "Transferred {eddies} €$ to your account!"; }
  public static func RedeemErrorNotEnough() -> String { return "Error: Not enough data."; }

  // Away-Progress Messages
  public static func AwayMsgCapReached() -> String { return "NODE RECONNECT: {amount} data generated. (Cap Reached: {cap}h)"; }
  public static func AwayMsgHoursElapsed() -> String { return "NODE RECONNECT: {amount} data generated ({hours}h elapsed)."; }
  public static func AwayMsgWhileAway() -> String { return "NODE RECONNECT: {amount} data generated while away."; }

  // Shop - Page Headers
  public static func HeaderAutoGenerators() -> String { return "== AUTO GENERATORS =="; }
  public static func HeaderSystemUpgrades() -> String { return "== SYSTEM UPGRADES =="; }

  // Shop - Generator Names (also used in purchase messages)
  public static func GenNameT1() -> String { return "Script Kiddie"; }
  public static func GenNameT2() -> String { return "Netrunner Daemon"; }
  public static func GenNameT3() -> String { return "AI Sub-Routine"; }
  public static func GenNameT4() -> String { return "Blackwall Specter"; }

  // Shop - Generator Entry Labels
  public static func GenBotEntry() -> String { return "[ {name} | Own: {count} (x{mult}){milestone} | Cost: {cost} ]"; }

  // Shop - Upgrade Names (also used in purchase messages)
  public static func UpgNameT1() -> String { return "Basic Overclock"; }
  public static func UpgNameT2() -> String { return "Neural Link"; }
  public static func UpgNameT3() -> String { return "Blackwall Bypass"; }
  public static func UpgNameCap() -> String { return "Memory Cap"; }

  // Shop - Upgrade Entry Labels
  public static func UpgClickEntry() -> String { return "[ {name} (+{bonus}/c) | Lvl: {lvl} | Cost: {cost} ]"; }
  public static func UpgCapEntry() -> String { return "[ Expand MEMORY CAP (+1h) | Lvl: {lvl} | Cost: {cost} ]"; }

  // Milestone Strings
  public static func MilestoneNext() -> String { return " -> x{mult} @ {remaining} more"; }
  public static func MilestoneMax() -> String { return " [MAX BONUS]"; }

  // Purchase / Error Messages
  public static func MsgInvalidCost() -> String { return "Invalid cost."; }
  public static func MsgNotEnoughData() -> String { return "Not enough data. Need {cost}."; }
  public static func MsgPurchased() -> String { return "Purchased {what} (-{cost} data)."; }

  // Achievements Page
  public static func AchPageHeader() -> String { return "Achievements"; }

  // Row formatting
  public static func AchRowClaimed() -> String { return "[CLAIMED] {title}  {progress}  |  {reward}"; }
  public static func AchRowClaimable() -> String { return ">> {title}  {progress}  |  {reward}  [CLAIM]"; }
  public static func AchRowLocked() -> String { return "{title}  {progress}  |  {reward}"; }

  // Achievement #1 - First Byte
  public static func AchName1() -> String { return "First Byte"; }
  public static func AchProg1() -> String { return "({n}/1 clicks)"; }
  public static func AchReward1() -> String { return "+200 DATA"; }
  public static func AchMsg1() -> String { return "Achievement: First Byte! +200 DATA"; }

  // Achievement #2 - Data Miner
  public static func AchName2() -> String { return "Data Miner"; }
  public static func AchProg2() -> String { return "({n}/100 clicks)"; }
  public static func AchReward2() -> String { return "+1,000 DATA"; }
  public static func AchMsg2() -> String { return "Achievement: Data Miner! +1,000 DATA"; }

  // Achievement #3 - Click Maniac
  public static func AchName3() -> String { return "Click Maniac"; }
  public static func AchProg3() -> String { return "({n}/1000 clicks)"; }
  public static func AchReward3() -> String { return "+5,000 DATA"; }
  public static func AchMsg3() -> String { return "Achievement: Click Maniac! +5,000 DATA"; }

  // Achievement #4 - Legendary Netrunner
  public static func AchName4() -> String { return "Legendary Netrunner"; }
  public static func AchProg4() -> String { return "({n}/10000 clicks)"; }
  public static func AchReward4() -> String { return "+25,000 DATA"; }
  public static func AchMsg4() -> String { return "Achievement: Legendary Netrunner! +25,000 DATA"; }

  // Achievement #5 - Script Kiddie Squad
  public static func AchName5() -> String { return "Script Kiddie Squad"; }
  public static func AchProg5() -> String { return "({n}/10 T1 bots)"; }
  public static func AchReward5() -> String { return "+1 Netrunner Daemons"; }
  public static func AchMsg5() -> String { return "Achievement: Script Kiddie Squad! +1 Netrunner Daemons"; }

  // Achievement #6 - Bot Army
  public static func AchName6() -> String { return "Bot Army"; }
  public static func AchProg6() -> String { return "({n}/50 total bots)"; }
  public static func AchReward6() -> String { return "+15,000 DATA"; }
  public static func AchMsg6() -> String { return "Achievement: Bot Army! +15,000 DATA"; }

  // Achievement #7 - Bot Empire
  public static func AchName7() -> String { return "Bot Empire"; }
  public static func AchProg7() -> String { return "({n}/100 total bots)"; }
  public static func AchReward7() -> String { return "+1 Blackwall Specter"; }
  public static func AchMsg7() -> String { return "Achievement: Bot Empire! +1 Blackwall Specter"; }

  // Achievement #8 - Daemon Whisperer
  public static func AchName8() -> String { return "Daemon Whisperer"; }
  public static func AchProg8() -> String { return "({n}/25 T2 bots)"; }
  public static func AchReward8() -> String { return "+2 AI Sub-Routines"; }
  public static func AchMsg8() -> String { return "Achievement: Daemon Whisperer! +2 AI Sub-Routines"; }

  // Achievement #9 - Beyond the Wall
  public static func AchName9() -> String { return "Beyond the Wall"; }
  public static func AchProg9() -> String { return "({n}/5 T4 bots)"; }
  public static func AchReward9() -> String { return "+50,000 DATA"; }
  public static func AchMsg9() -> String { return "Achievement: Beyond the Wall! +50,000 DATA"; }

  // Achievement #10 - First Payday
  public static func AchName10() -> String { return "First Payday"; }
  public static func AchProg10() -> String { return "({n}/1 redeems)"; }
  public static func AchReward10() -> String { return "+3,000 DATA"; }
  public static func AchMsg10() -> String { return "Achievement: First Payday! +3,000 DATA"; }

  // Achievement #11 - Overclocker
  public static func AchName11() -> String { return "Overclocker"; }
  public static func AchProg11() -> String { return "({n}/50 PPC)"; }
  public static func AchReward11() -> String { return "+10,000 DATA"; }
  public static func AchMsg11() -> String { return "Achievement: Overclocker! +10,000 DATA"; }

  // Achievement #12 - Memory Expansion
  public static func AchName12() -> String { return "Memory Expansion"; }
  public static func AchProg12() -> String { return "({n}/5 cap upgrades)"; }
  public static func AchReward12() -> String { return "+35,000 DATA"; }
  public static func AchMsg12() -> String { return "Achievement: Memory Expansion! +35,000 DATA"; }

  // Achievement #13 - Subnet Lord
  public static func AchName13() -> String { return "Subnet Lord"; }
  public static func AchProg13() -> String { return "({n}/200 total bots)"; }
  public static func AchReward13() -> String { return "+150,000 DATA"; }
  public static func AchMsg13() -> String { return "Achievement: Subnet Lord! +150,000 DATA"; }

  // Achievement #14 - Quick Hack
  public static func AchName14() -> String { return "Quick Hack"; }
  public static func AchProg14() -> String { return "({n}/100 PPC)"; }
  public static func AchReward14() -> String { return "+2 AI Sub-Routines"; }
  public static func AchMsg14() -> String { return "Achievement: Quick Hack! +2 AI Sub-Routines"; }

  // Achievement #15 - Data Hoarder
  public static func AchName15() -> String { return "Data Hoarder"; }
  public static func AchProg15() -> String { return "({n}/1M DATA held)"; }
  public static func AchReward15() -> String { return "+5000 €$"; }
  public static func AchMsg15() -> String { return "Achievement: Data Hoarder! +5000 €$"; }

  // Achievement #16 - Net Profit
  public static func AchName16() -> String { return "Net Profit"; }
  public static func AchProg16() -> String { return "({n}/10 redeems)"; }
  public static func AchReward16() -> String { return "+50,000 DATA"; }
  public static func AchMsg16() -> String { return "Achievement: Net Profit! +50,000 DATA"; }

  // Achievement #17 - Mass Production
  public static func AchName17() -> String { return "Mass Production"; }
  public static func AchProg17() -> String { return "({n}/10 T3 bots)"; }
  public static func AchReward17() -> String { return "+1 Blackwall Specters"; }
  public static func AchMsg17() -> String { return "Achievement: Mass Production! +1 Blackwall Specters"; }

  // Achievement #18 - Specter Network
  public static func AchName18() -> String { return "Specter Network"; }
  public static func AchProg18() -> String { return "({n}/25 T4 bots)"; }
  public static func AchReward18() -> String { return "+300,000 DATA"; }
  public static func AchMsg18() -> String { return "Achievement: Specter Network! +300,000 DATA"; }

  // Achievement #19 - Mega Clicker
  public static func AchName19() -> String { return "Mega Clicker"; }
  public static func AchProg19() -> String { return "({n}/50000 clicks)"; }
  public static func AchReward19() -> String { return "+300,000 DATA"; }
  public static func AchMsg19() -> String { return "Achievement: Mega Clicker! +300,000 DATA"; }

  // Achievement #20 - Neural Master
  public static func AchName20() -> String { return "Neural Master"; }
  public static func AchProg20() -> String { return "({n}/250 PPC)"; }
  public static func AchReward20() -> String { return "+10000 €$"; }
  public static func AchMsg20() -> String { return "Achievement: Neural Master! +10000 €$"; }

  // Achievement #21 - Sysadmin
  public static func AchName21() -> String { return "Sysadmin"; }
  public static func AchProg21() -> String { return "({n}/10 cap upgrades)"; }
  public static func AchReward21() -> String { return "+100,000 DATA"; }
  public static func AchMsg21() -> String { return "Achievement: Sysadmin! +100,000 DATA"; }

  // Achievement #22 - Silverhand Protocol
  public static func AchName22() -> String { return "Silverhand Protocol"; }
  public static func AchProg22() -> String { return "({n}/10000 auto/m)"; }
  public static func AchReward22() -> String { return "+15000 €$"; }
  public static func AchMsg22() -> String { return "Achievement: Silverhand Protocol! +15000 €$"; }
}
