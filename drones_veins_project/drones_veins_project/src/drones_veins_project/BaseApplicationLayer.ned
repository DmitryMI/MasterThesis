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

package org.car2x.veins.subprojects.drones_veins_project;

import org.car2x.veins.modules.application.ieee80211p.DemoBaseApplLayer;

module BaseApplicationLayer extends DemoBaseApplLayer
{
    parameters:
        @class(drones_veins_project::BaseApplicationLayer);
        @display("i=block/app2");  
       
       	string rebroadcastDeciderTypePrefix = default("org.car2x.veins.subprojects.drones_veins_project.rebroadcasting");
        string rebroadcastDeciderClassName = default("WeightedPPersistenceDecider");
        
    gates:
        input rebroadcastDeciderInGate @directIn;
                	    
    submodules:
   	    rebroadcastDecider: <rebroadcastDeciderTypePrefix + "." + rebroadcastDeciderClassName> like org.car2x.veins.subprojects.drones_veins_project.rebroadcasting.IRebroadcastDecider
   	    {
   	        parameters:
   	            @display("p=80, 80");
   	    }
   	    
}