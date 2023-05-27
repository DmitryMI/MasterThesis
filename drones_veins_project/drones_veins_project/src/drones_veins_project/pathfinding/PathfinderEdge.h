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
	class PathfinderEdge;

	class PathfinderLane
	{
		std::string id;
		int index;
		double length;
		std::vector<veins::TraCICoord> shape;

		PathfinderEdge* owningEdge = nullptr;

	public:
		PathfinderLane(const std::string& id, int index, double length, const std::vector<veins::TraCICoord>& shape);

		friend class Pathfinder;
		friend class PathfinderEdge;
	};

	class PathfinderEdge
	{
	private:
		std::string id;
		std::string fromJunctionId;
		std::string toJunctionId;

		std::vector<PathfinderEdge*> connectedEdges;
		std::vector<PathfinderLane*> lanes;
		PathfinderJunction *fromJunction = nullptr;
		PathfinderJunction *toJunction = nullptr;
		bool isInternal;
	public:
		PathfinderEdge(const std::string& id, const std::string&  fromId, const std::string&  toId, bool isInternal);
		double getLengthTraci() const;

		friend class Pathfinder;
	};
}

#endif /* DRONES_VEINS_PROJECT_PATHFINDING_PATHFINDEREDGE_H_ */
