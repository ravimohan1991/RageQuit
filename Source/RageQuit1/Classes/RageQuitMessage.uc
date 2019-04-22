/*
 *   --------------------------
 *  |  RageQuitMessage.uc
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
 * This class is responsible for playing the RageQuit sound and <br />
 * showing the RageQuit message!
 *
 * @author The_Cowboy
 * @version 1.0
 * @since 1.0
 */

class RageQuitMessage extends CriticalEventPlus;

/*
 * Global Variables
 */

 /** The RageQuit message. */
 var  localized  string                         RageQuitMessage;

/**
 * The function gets called by the Level.Game.BroadcastLocalized through
 * the BroadcastHandler
 *
 * @param Switch Identification number of multiple messages.
 * @param RelatedPRI_1 PlayerReplicationInfo of the involved player. Eg The_Cowboy in "The_Cowboy is sealing off the base!"
 * @param RelatedPRI_2 PlayerReplicationInfo of another involved player.
 * @param OptionalObject Nothing
 *
 * @see RageQuit.ModifyPlayer
 * @since version 1.0
 */

 static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	){

    if(RelatedPRI_1 == none)
	   return "";

    switch(Switch){
       case 0:  // RageQuitter
          return default.RageQuitMessage;
          break;
    }
 }


/**
 * The function also gets called by the Level.Game.BroadcastLocalized through
 * the BroadcastHandler
 *
 * @param Switch Identification number of multiple messages.
 * @param RelatedPRI_1 PlayerReplicationInfo of the involved player. Eg The_Cowboy in "The_Cowboy is sealing off the base!"
 * @param RelatedPRI_2 PlayerReplicationInfo of another involved player.
 * @param OptionalObject Nothing
 *
 * @see RageQuit.ModifyPlayer
 * @since version 1.0
 */

 static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	){

    local Sound RageSound;

    Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

    if (RelatedPRI_1 != P.PlayerReplicationInfo)
		return;

	RageSound = sound(DynamicLoadObject("RageQuit1.SRageQuit", class'Sound', true));
	if(RageSound != none)
	   Log("The RageSound loaded is"@RageSound.Name, 'RageQuit');
    else
       Log("Couldn't load the RageSound.",'RageQuit');

    if(P.ViewTarget != none)
       P.ViewTarget.PlaySound(RageSound, SLOT_Talk, 4, , , , false);
 }

 defaultproperties
 {
    RageQuitMessage="R A G E   Q U I T!"
    PosY=0.5
    DrawColor=(B=0,G=0,R=255)
 }
