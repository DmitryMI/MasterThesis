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

package org.car2x.veins.subprojects.drones_veins_project.rebroadcasting;

simple WeightedPPersistenceDecider like IRebroadcastDecider
{
    parameters:
        @class(drones_veins_project::WeightedPPersistenceDecider);
        @display("i=block/app2");  
        
        double waitTime @unit(s) = default(200ms);
        double waitTimeDeviation @unit(s) = default(50ms);
        double deltaTime @unit(s) = default(100ms);
        double averageTransmissionRange @unit(m) = default(500m);
        
        // Required by interface, not used actually
        double rebroadcastProbability = 1.0;
        
        bool showBubbles = default(false);
        
    gates:
    	input parentInGate @directIn;
     
}