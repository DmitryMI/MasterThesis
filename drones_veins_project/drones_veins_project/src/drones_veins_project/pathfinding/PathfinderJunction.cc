/*
 * PathfinderJunction.cpp
 *
 *  Created on: May 22, 2023
 *      Author: dmitriy
 */

#include "PathfinderJunction.h"
#include "PathfinderEdge.h"
#include <vector>

using namespace drones_veins_project;

PathfinderJunction::PathfinderJunction(std::string id, const std::vector<PathfinderLane*>& incomingLanes, const std::vector<PathfinderLane*>& internalLanes, bool isInternal)
{
	this->id = id;
	this->incomingLanes = incomingLanes;
	this->internalLanes = internalLanes;
	this->isInternal = isInternal;
}
