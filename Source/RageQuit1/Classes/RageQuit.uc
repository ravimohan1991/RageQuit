/*
 *   --------------------------
 *  |  RageQuit.uc
 *   --------------------------
 *   This file is part of RageQuit mutator.
 *
 *   RageQuit is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   RageQuit is distributed in the hope and belief that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with RageQuit.  if not, see <https://www.gnu.org/licenses/>.
 *
 *   "the word of the LORD came expressly unto Ezekiel the priest, the son of Buzi,
 *   in the land of the Chaldeans by the river Chebar; and the hand of the LORD
 *   was there upon him."
 */

/**
 * RageQuit is a mutator to identify the players ragequitting    <br />
 * from the game and broadcast the appropriate announcement when <br />
 * they rejoin the server next time.                             <br />
 *                                                               <br />
 * The detection algorithm is based on the thread                <br />
 * https://miasma.org/index.php?topic=1367.0
 *
 * @author The_Cowboy
 * @version 1.0
 * @since 1.0
 */

class RageQuit extends Mutator config (RageQuit);

#exec AUDIO IMPORT FILE="Sounds\RageQuitQuake2SFX.wav" NAME="SRageQuit"

/*
 * Structures
 */

 struct PlayerInfo{
   var string PName;
   var float KilledTimeSecond;
 };

 struct TeamSInfo{
   var float Score;
   var float ScoreTime;
 };
/*
 * Global Variables
 */

 /** String with Version of the Mutator.*/
 var   string                                     Version;

 /** Structure array with current player name and time.*/
 var   array<PlayerInfo>                          PInfo;

 /** Team score and scoretime structure array .*/
 var   TeamSInfo                                  TSInfo[2];

 /** RageQuitGameRules reference*/
 var   RageQuitGameRules                          RQGRules;


 /*
  * Configurable variables.
  */

 /** Seconds after getting killed to determine if it is a RageQuit. */
 var()  config   float                                      KilledRageQuitSeconds;

 /** Seconds after opposite team scoretime to determine if it is a RageQuit. */
 var()  config   float                                      OTeamRageQuitSeconds;

 /** String array of rage quitters! */
 var()  config   array<string>                              RageQuitters;

/**
 * The function gets called just after game begins. So we set up the
 * environmnet for RageQuit to operate.
 *
 * @since version 1A
 */

 function PostBeginPlay(){

     SaveConfig();
     RQGRules = Level.Game.Spawn(class'RageQuitGameRules');
     RQGRules.RQMut = self;
     Level.Game.AddGameModifier(RQGRules);
     super.PostBeginPlay();
 }


/**
 * The function to check if Rage Quit routine should be
 * broadcasted to the Player.
 *
 * @param Other The Pawn instance of humanplayer or bot
 * @since version 1.0
 */

 function ModifyPlayer(Pawn Other){

    local int i;

    if(PlayerController(Other.Controller) != none){
       for(i = 0; i < RageQuitters.Length; i++){
          if(RageQuitters[i] == Other.PlayerReplicationInfo.PlayerName){
             BroadcastRageQuit(Other);
             RageQuitters.Remove(i, 1);
             SaveConfig();
             i = 0;
          }
       }
    }

    if(NextMutator != None)
	   NextMutator.ModifyPlayer(Other);
 }

/**
 * Routine to broadcast the rage quit message to clients with the
 * Announcer effects.                                  <br />
 * The sound is from  https://www.youtube.com/watch?v=AAk2ZYDeJc4
 *
 * @since version 1.0
 */

 function BroadcastRageQuit(Pawn Other){

    Level.Game.Broadcast(self, "Notified"@Other.PlayerReplicationInfo.PlayerName@"about last time's Rage Quit!");
    Level.Game.BroadcastHandler.BroadcastLocalized(none, PlayerController(Other.Controller), class'RageQuitMessage', 0, Other.PlayerReplicationInfo);
 }

 /**
 * The function for checking if the exiting player is ragequitter!
 *
 * @since version 1.0
 */

 function NotifyLogout(Controller Exiting){

    local int i;

    super.NotifyLogout(Exiting);

    if(PlayerController(Exiting) == none) return;// Bots don't ragequit!

    if(Exiting.PlayerReplicationInfo.bIsSpectator || Exiting.PlayerReplicationInfo.bWaitingPlayer)
       return;

    for(i = 0; i < PInfo.Length; i++){
       if(PInfo[i].PName == Exiting.PlayerReplicationInfo.PlayerName)
       break;
    }

    if(i == PInfo.Length) return;
    else{
       if(Level.TimeSeconds - PInfo[i].KilledTimeSecond <= KilledRageQuitSeconds ||
          Level.TimeSeconds - TSInfo[1 - Exiting.PlayerReplicationInfo.Team.TeamIndex].ScoreTime <= OTeamRageQuitSeconds){
          RageQuitters[RageQuitters.Length] = Exiting.PlayerReplicationInfo.PlayerName;
          SaveConfig();
       }
    }

 }

/**
 * Method to memorize the killed time.
 *
 * @param Killed The Pawn class getting screwed.
 * @param Killer The Controller class screwing around.
 * @param damageType The nature of damage.
 * @param HitLocation The place of crime.
 *
 * @see #RageQuitGameRules.PreventDeath(Killed, Killer, damageType, HitLocation)
 * @since version 1.0
 */

 function EvaluateKillingEvent(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation){

    local PlayerReplicationInfo KilledPRI;
    local PlayerInfo LPI;
    local int i;

    if(PlayerController(Killed.Controller) == none || Killed == none || Killed.Controller == none) return;
    KilledPRI = Killed.PlayerReplicationInfo;
    if(KilledPRI == none || (KilledPRI.bIsSpectator && !KilledPRI.bWaitingPlayer)) return;

    if(Killer == none || Killer == Killed.Controller)// Suicide
       return;

    for(i = 0; i < PInfo.Length; i++){
       if(PInfo[i].PName == Killed.PlayerReplicationInfo.PlayerName)
          break;
    }

    LPI.KilledTimeSecond = Level.TimeSeconds;
    LPI.PName = KilledPRI.PlayerName;
    PInfo[i] = LPI;
 }

/**
 * Method to memorize the scoring time.
 *
 * @param Scorer The PlayerReplicationInfo class of the Scorer
 *
 * @see #RageQuitGameRules.CheckScore(Other)
 * @since version 1.0
 */

 function EvaluateScoreEvent(PlayerReplicationInfo Scorer){

    if(Scorer.Team.Score > TSInfo[Scorer.Team.TeamIndex].Score && Scorer.Team.Score < Level.Game.GoalScore && !Level.Game.bOverTime){// Ok this is scoring event
       TSInfo[Scorer.Team.TeamIndex].Score = Scorer.Team.Score;
       TSInfo[Scorer.Team.TeamIndex].ScoreTime = Level.TimeSeconds;
      // Level.Game.Broadcast(none, Scorer.PlayerName@"Scored for the team!");
    }
 }

defaultproperties
 {
    Version="1.0"
    KilledRageQuitSeconds=5.0
    OTeamRageQuitSeconds=5.0
 }
