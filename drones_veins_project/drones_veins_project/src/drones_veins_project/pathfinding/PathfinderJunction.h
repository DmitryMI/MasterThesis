/*
 * PathfinderJunction.h
 *
 *  Created on: May 22, 2023
 *      Author: dmitriy
 */

#ifndef DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDERJUNCTION_H_
#define DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDERJUNCTION_H_

#include <string>
#include "../drones_veins_project.h"


namespace drones_veins_project
{
	class PathfinderLane;

	class PathfinderJunction
	{
	private:
		std::string id;
		bool isInternal;

		std::vector<PathfinderLane*> incomingLanes;
		std::vector<PathfinderLane*> internalLanes;

	public:
		PathfinderJunction(std::string id, const std::vector<PathfinderLane*>& incomingLanes, const std::vector<PathfinderLane*>& internalLanes, bool isInternal);

		friend class Pathfinder;
	};
}
#endif /* DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDERJUNCTION_H_ */
