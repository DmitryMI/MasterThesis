/*
 * SumoEdge.cpp
 *
 *  Created on: May 22, 2023
 *      Author: dmitriy
 */

#include "PathfinderEdge.h"

using namespace drones_veins_project;

PathfinderLane::PathfinderLane(const std::string& id, int index, double length, const std::vector<veins::TraCICoord>& shape)
{
	this->id = id;
	this->index = index;
	this->length = length;
	this->shape = shape;
}

PathfinderEdge::PathfinderEdge(const std::string& id, const std::string&  fromId, const std::string& toId, bool isInternal)
{
	this->id = id;
	this->fromJunctionId = fromId;
	this->toJunctionId = toId;
	this->isInternal = isInternal;
}

double PathfinderEdge::getLengthTraci() const
{
	if(lanes.size() > 0)
	{
		PathfinderLane* lane = lanes[0];
		return lane->length;
	}
	return 0;
}
