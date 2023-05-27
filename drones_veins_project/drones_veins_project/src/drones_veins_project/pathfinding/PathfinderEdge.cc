/*
 * SumoEdge.cpp
 *
 *  Created on: May 22, 2023
 *      Author: dmitriy
 */

#include "PathfinderEdge.h"

using namespace drones_veins_project;

PathfinderEdge::PathfinderEdge(const std::string& id, const std::string&  fromId, const std::string&  toId, const veins::TraCICoord& startCoord,
		const veins::TraCICoord& endCoord, bool isInternal)
{
	this->id = id;
	this->fromJunctionId = fromId;
	this->toJunctionId = toId;
	this->startCoord = startCoord;
	this->endCoord = endCoord;
	this->isInternal = isInternal;
}

double PathfinderEdge::getLengthTraci() const
{
	double dx = endCoord.x - startCoord.x;
	double dy = endCoord.y - startCoord.y;
	return std::sqrt(dx * dx + dy * dy);
}
