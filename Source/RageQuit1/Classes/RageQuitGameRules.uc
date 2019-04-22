/*
 *   --------------------------
 *  |  RageQuitgameRules.uc
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
 * This class is for tracking the Killing events in the Game.
 *
 * @see RageQuit.PostBeginPlay()
 *
 * @author The_Cowboy
 * @version 1.0
 * @since 1.0
 */

class RageQuitGameRules extends GameRules;

/*
 * Global Variables
 */

 /** The RageQuit reference.*/
 var RageQuit RQMut;

/**
 * Method to notify RageQuit about the killings.
 *
 * @param Killed The Pawn class getting screwed.
 * @param Killer The Controller class screwing around.
 * @param damageType The nature of damage.
 * @param HitLocation The place of crime.
 *
 * @see #Engine.GameInfo.PreventDeath(Killed, Killer, damageType, HitLocation)
 * @since version 1.0
 */

 function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation){

     if ( (NextGameRules != None) && NextGameRules.PreventDeath(Killed,Killer, damageType,HitLocation) )
	    return true; // No Killing! So return.
     RQMut.EvaluateKillingEvent(Killed, Killer, damageType, HitLocation);
     return false;
 }


/**
 * Function to see if the score means game has ended.  We don't decide
 * that here. We just notify the RageQuit mutator that team score might
 * have incremented and then it checks if there are any Rage Quits due to
 * this event.
 *
 * @param Scorer The PlayerReplicationInfo class of the Player who scored
 * @since version 1.0
 */

 function bool CheckScore(PlayerReplicationInfo Scorer){

	if ( (NextGameRules != None && NextGameRules.CheckScore(Scorer)) || Level.Game.GameReplicationInfo.Winner != none)
		return true;// See if game ended. Then disconnecting is not ragequitting
	// The Game in progress
    RQMut.EvaluateScoreEvent(Scorer);
	return false;
}

