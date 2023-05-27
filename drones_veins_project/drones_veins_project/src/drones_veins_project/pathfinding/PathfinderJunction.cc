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

PathfinderJunction::PathfinderJunction(std::string id, std::vector<std::string> incomingLaneIds, bool isInternal)
{
	this->id = id;
	this->incomingLaneIds = incomingLaneIds;
	this->isInternal = isInternal;
}
