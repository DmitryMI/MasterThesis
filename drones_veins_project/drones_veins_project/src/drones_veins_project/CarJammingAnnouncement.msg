//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

cplusplus {{
#include "veins/base/utils/Coord.h"
#include "veins/modules/messages/BaseFrame1609_4_m.h"
#include "veins/base/utils/SimpleAddress.h"
}}

namespace drones_veins_project;

class veins::BaseFrame1609_4;
class noncobject veins::Coord;
class veins::LAddress::L2Type extends void;

packet CarJammingAnnouncement extends BaseFrame1609_4 {    
    veins::LAddress::L2Type senderAddress = -1;
    long serial = 0;
    long hop = 1;
    
    string carRoadId;
    veins::Coord carPosition;
    simtime_t senderTimestamp;
    
    veins::Coord lastRebroadcasterPosition;
}