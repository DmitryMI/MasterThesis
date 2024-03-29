//
// Copyright (C) 2017 Christoph Sommer <sommer@ccs-labs.org>
//
// Documentation for these modules is at http://veins.car2x.org/
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//


package org.car2x.veins.subprojects.drones_veins_project;

import org.car2x.veins.base.connectionManager.ConnectionManager;
import org.car2x.veins.base.modules.BaseWorldUtility;
import org.car2x.veins.modules.mobility.traci.*;
import org.car2x.veins.modules.obstacle.IObstacleControl;
import org.car2x.veins.modules.world.annotations.AnnotationManager;
import org.car2x.veins.nodes.Car;
import org.car2x.veins.visualizer.roads.RoadsCanvasVisualizer;
import org.car2x.veins.visualizer.roads.RoadsOsgVisualizer;
import org.car2x.veins.subprojects.drones_veins_project.cars.Car3d;
import org.car2x.veins.subprojects.drones_veins_project.pathfinding.Pathfinder;
import org.car2x.veins.subprojects.drones_veins_project.drones.Drone;
import org.car2x.veins.subprojects.drones_veins_project.drones.DroneManager;
import org.car2x.veins.subprojects.drones_veins_project.ObstacleControl3d;
import org.car2x.veins.subprojects.drones_veins_project.visualizers.*;

network DronesScenario
{
    parameters:
        double playgroundSizeX @unit(m); // x size of the area the nodes are in (in meters)
        double playgroundSizeY @unit(m); // y size of the area the nodes are in (in meters)
        double playgroundSizeZ @unit(m); // z size of the area the nodes are in (in meters)
        @display("bgb=$playgroundSizeX,$playgroundSizeY");
        
        string obstacleControlType = default("ObstacleControl3d");
        string carType = default("org.car2x.veins.subprojects.drones_veins_project.cars.Car3d");
        string traciScenarioManagerType = default("org.car2x.veins.modules.mobility.traci.TraCIScenarioManagerLaunchd");
        
    submodules:
        drone[0]: Drone {            
        }
        
        droneManager : DroneManager{
             parameters:
                @display("p=290,0");
        }
        
        obstacles: ObstacleControl3d {
            @display("p=300,0");
        }
        
        annotations: AnnotationManager {
            @display("p=310,0");
        }
        
        connectionManager: ConnectionManager {
            parameters:
                @display("p=320,0;i=abstract/multicast");
        }
        
        world: BaseWorldUtility {
            parameters:
                playgroundSizeX = veins_eval_by_version(veins_omnetpp_buildnum(), "playgroundSizeX", 1525, "parent.playgroundSizeX");
                playgroundSizeY = veins_eval_by_version(veins_omnetpp_buildnum(), "playgroundSizeY", 1525, "parent.playgroundSizeY");
                playgroundSizeZ = veins_eval_by_version(veins_omnetpp_buildnum(), "playgroundSizeZ", 1525, "parent.playgroundSizeZ");
                @display("p=330,0;i=misc/globe");
        }
        
       	
        manager: <traciScenarioManagerType> like ITraciScenarioManager{
            parameters:
                @display("p=340,0");
                moduleType = carType;
        }
        
        inserter: TraCIVehicleInserter {
            
        }
        
        vehicleCounter: VehicleCounter {
            @display("p=350,0");
        }
        
        pathfinder: Pathfinder {
            @display("p=360,0");
        }
 
        roadsCanvasVisualizer: RoadsCanvasVisualizer {
            @display("p=370,0");
        }
        
        roadsOsgVisualizer: RoadsOsgVisualizer2 {
            @display("p=380,0");
        }
        
        osgManager: OsgManager {
            @display("p=390,0");
        }
        
        obstacleShadowingVisualizer: ObstacleShadowingVisualizer {
            @display("p=400,0");
        }
        
        node[0]: Car3d {
        }

    connections allowunconnected:
}
