/*
 * SumoEdge.h
 *
 *  Created on: May 22, 2023
 *      Author: dmitriy
 */

#ifndef DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDEREDGE_H_
#define DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDEREDGE_H_

#include <string>
#include "../drones_veins_project.h"
#include "omnetpp.h"
#include "veins/modules/mobility/traci/TraCICoord.h"
#include <cmath>
#include "PathfinderJunction.h"


namespace drones_veins_project
{
	class PathfinderJunction;

	class PathfinderEdge
	{
	private:
		std::string id;
		std::string fromJunctionId;
		std::string toJunctionId;
		veins::TraCICoord startCoord;
		veins::TraCICoord endCoord;

		std::vector<PathfinderEdge*> connectedEdges;
		PathfinderJunction *fromJunction;
		PathfinderJunction *toJunction;
		bool isInternal;
	public:
		PathfinderEdge(const std::string& id, const std::string&  fromId, const std::string&  toId, const veins::TraCICoord& startCoord,
				const veins::TraCICoord& endCoord, bool isInternal);
		double getLengthTraci() const;

		friend class Pathfinder;
	};
}

#endif /* DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDEREDGE_H_ */
