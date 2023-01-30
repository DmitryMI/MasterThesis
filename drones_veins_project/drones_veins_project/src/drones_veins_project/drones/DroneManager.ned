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

package org.car2x.veins.subprojects.drones_veins_project.drones;

simple DroneManager
{
    parameters:
        @display("i=block/network2");
        @class(drones_veins_project::DroneManager);
        
        // Time interval of position updates        
        double updateInterval @unit("s") = default(1s); 
         			
        // Module type to be used in the simulation for each managed vehicle        
        string moduleType = default("org.car2x.veins.subprojects.drones_veins_project.drones.Drone");  	
        
        // Module name to be used in the simulation for each managed vehicle
        string moduleName = default("drone");  	
        
        string moduleDisplayString = default("i=veins/node/drone,blue;is=vs;");	
        
        double droneLocationZ @unit("m") = default(300m);
        
        int numberOfDrones = default(10);
}