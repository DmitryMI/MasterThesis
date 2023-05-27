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
	class PathfinderEdge;

	class PathfinderJunction
	{
	private:
		std::string id;
		std::vector<std::string> incomingLaneIds;
		bool isInternal;

	public:
		PathfinderJunction(std::string id, std::vector<std::string> incomingLaneIds, bool isInternal);

		friend class Pathfinder;
	};
}
#endif /* DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDERJUNCTION_H_ */
