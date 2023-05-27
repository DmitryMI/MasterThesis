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

#include "Pathfinder.h"
#include "veins/base/utils/FindModule.h"
#include "veins/modules/mobility/traci/TraCIScenarioManager.h"
#include "veins/modules/mobility/traci/TraCIConnection.h"

using namespace omnetpp;
using namespace veins;
using namespace drones_veins_project;

Define_Module(drones_veins_project::Pathfinder);

Pathfinder::Pathfinder()
{
	// TODO Auto-generated constructor stub

}

Pathfinder::~Pathfinder()
{
	for (auto lanePair : lanes)
	{
		delete lanePair.second;
	}
	for (auto edgePair : edges)
	{
		delete edgePair.second;
	}
	for (auto junctionPair : junctions)
	{
		delete junctionPair.second;
	}

}

std::vector<std::string> Pathfinder::parseEdgeList(const std::string &incLanes)
{
	std::vector<std::string> res;

	std::string token = "";
	for (uint64_t i = 0; i < incLanes.size(); i++)
	{
		if (incLanes[i] == ' ')
		{
			if (!token.empty())
			{
				res.push_back(token);
				token = "";
			}
		}
		else if (incLanes[i] == '_')
		{
			ASSERT(!token.empty());
			while (incLanes[i] != ' ' && i < incLanes.size())
			{
				i++;
			}
			i--;
		}
		else
		{
			token += incLanes[i];
		}
	}

	if (!token.empty())
	{
		res.push_back(token);
	}

	return res;
}

std::vector<std::string> Pathfinder::parseLaneList(const std::string &lanes)
{
	std::vector<std::string> res;

	std::string token = "";
	for (uint64_t i = 0; i < lanes.size(); i++)
	{
		if (lanes[i] == ' ')
		{
			if (!token.empty())
			{
				res.push_back(token);
				token = "";
			}
		}
		else
		{
			token += lanes[i];
		}
	}

	if (!token.empty())
	{
		res.push_back(token);
	}

	return res;
}

veins::TraCICoord Pathfinder::parseCoord(const std::vector<std::string> &tokens)
{
	std::array<float, 3> items = { 0, 0, 0 };
	veins::TraCICoord coord;

	ASSERT(tokens.size() == 2);

	for (uint64_t j = 0; j < tokens.size(); j++)
	{
		items[j] = std::stof(tokens[j]);
	}

	coord.x = items[0];
	coord.y = items[1];
	return coord;
}

std::vector<veins::TraCICoord> Pathfinder::parseShape(const std::string &shapeStr)
{
	std::vector<veins::TraCICoord> res;

	std::string token;
	std::vector<std::string> tokens;

	for (uint64_t i = 0; i < shapeStr.size(); i++)
	{
		if (shapeStr[i] == ' ')
		{
			if (!token.empty())
			{
				tokens.push_back(token);
				token = "";
			}
			veins::TraCICoord coord = parseCoord(tokens);
			tokens.clear();
			res.push_back(coord);
		}
		else if (shapeStr[i] == ',')
		{
			if (!token.empty())
			{
				tokens.push_back(token);
				token = "";
			}
		}
		else
		{
			token += shapeStr[i];
		}
	}

	if (!token.empty())
	{
		tokens.push_back(token);
		veins::TraCICoord coord = parseCoord(tokens);
		res.push_back(coord);
	}

	return res;
}

void Pathfinder::initialize(int stage)
{
	if (stage != 0)
	{
		return;
	}

	cXMLElement *xml = par("sumoNetworkXml").xmlValue();

	std::string rootTag = xml->getTagName();
	if (rootTag != "net")
	{
		throw cRuntimeError("SUMO Net definition root tag was \"%s\", but expected \"net\"", rootTag.c_str());
	}

	cXMLElementList list = xml->getChildren();

	for (cXMLElement *child : list)
	{
		std::string tagName = child->getTagName();
		if (tagName == "edge")
		{
			auto functionAttrChar = child->getAttribute("function");
			bool isInternal = false;
			if (functionAttrChar != nullptr)
			{
				std::string functionAttr = functionAttrChar;
				if (functionAttr == "internal")
				{
					isInternal = true;
				}
			}

			std::string edgeId = child->getAttribute("id");

			std::string fromId = "";
			const char *fromIdChar = child->getAttribute("from");
			if (fromIdChar)
			{
				fromId = fromIdChar;
			}

			std::string toId = "";
			const char *toIdChar = child->getAttribute("to");
			if (toIdChar)
			{
				toId = toIdChar;
			}

			PathfinderEdge *edge = new PathfinderEdge(edgeId, fromId, toId, isInternal);

			cXMLElementList edgeChildren = child->getChildren();
			for (cXMLElement *edgeChild : edgeChildren)
			{
				std::string edgeChildTag = edgeChild->getTagName();
				if (edgeChildTag != "lane")
				{
					continue;
				}
				std::string id = edgeChild->getAttribute("id");
				int index = std::atoi(edgeChild->getAttribute("index"));
				double length = std::atof(edgeChild->getAttribute("length"));

				std::vector<veins::TraCICoord> shape = { veins::TraCICoord(), veins::TraCICoord() };
				const char *shapeAttrChar = edgeChild->getAttribute("shape");
				if (shapeAttrChar != nullptr)
				{
					std::string shapeStr = edgeChild->getAttribute("shape");
					shape = parseShape(shapeStr);
				}
				PathfinderLane *lane = new PathfinderLane(id, index, length, shape);
				lane->owningEdge = edge;
				lanes.emplace(id, lane);

				edge->lanes.push_back(lane);
			}

			edges.emplace(edgeId, edge);
		}
		else if (tagName == "junction")
		{
			auto typeAttrChar = child->getAttribute("type");
			bool isInternal = false;
			if (typeAttrChar != nullptr)
			{
				std::string typeAttr = typeAttrChar;
				if (typeAttr == "internal")
				{
					isInternal = true;
				}
			}

			std::string junctionId = child->getAttribute("id");
			std::string incLaneIdsStr = child->getAttribute("incLanes");
			std::string intLaneIdsStr = child->getAttribute("intLanes");
			std::vector<std::string> incomingLaneIds = parseLaneList(incLaneIdsStr);
			std::vector<std::string> internalLaneIds = parseLaneList(intLaneIdsStr);

			std::vector<PathfinderLane*> incomingLanes;
			for (const std::string &incomingLaneId : incomingLaneIds)
			{
				PathfinderLane *incomingLane = lanes.at(incomingLaneId);
				incomingLanes.push_back(incomingLane);
			}

			std::vector<PathfinderLane*> internalLanes;
			for (const std::string &laneId : internalLaneIds)
			{
				PathfinderLane *internalLane = lanes.at(laneId);
				internalLanes.push_back(internalLane);
			}

			// Interconnect internal lanes
			for (uint64_t laneIndexI = 0; laneIndexI < internalLanes.size(); laneIndexI++)
			{
				PathfinderLane *laneI = internalLanes[laneIndexI];
				PathfinderEdge *edgeI = laneI->owningEdge;
				for (uint64_t laneIndexJ = laneIndexI + 1; laneIndexJ < internalLanes.size(); laneIndexJ++)
				{
					PathfinderLane *laneJ = internalLanes[laneIndexJ];
					PathfinderEdge *edgeJ = laneJ->owningEdge;
					edgeI->connectedEdges.push_back(edgeJ);
					edgeJ->connectedEdges.push_back(edgeI);
				}
			}

			// Connect incoming edges to internal lanes (edges)
			for(PathfinderLane* incomingLane : incomingLanes)
			{
				PathfinderEdge* incomingEdge = incomingLane->owningEdge;
				for(PathfinderLane* internalLane : internalLanes)
				{
					PathfinderEdge* internalEdge = internalLane->owningEdge;
					incomingEdge->connectedEdges.push_back(internalEdge);
				}
			}

			PathfinderJunction *junction = new PathfinderJunction(junctionId, incomingLanes, internalLanes, isInternal);
			junctions.emplace(junctionId, junction);
		}
		else if (tagName == "connection")
		{
			const char *fromIdChar = child->getAttribute("from");
			const char *toIdChar = child->getAttribute("to");

			std::string fromId = "";
			std::string toId = "";
			if (fromIdChar != nullptr)
			{
				fromId = std::string(fromIdChar);
			}
			if (toIdChar != nullptr)
			{
				toId = std::string(toIdChar);
			}

			ASSERT(edges.count(fromId) != 0 && edges.count(toId) != 0);

			PathfinderEdge *fromEdge = edges[fromId];
			PathfinderEdge *toEdge = edges[toId];
			fromEdge->connectedEdges.push_back(toEdge);
		}
	}

	for (auto edgePair : edges)
	{
		std::string fromId = edgePair.second->fromJunctionId;
		if (fromId.empty())
		{
			continue;
		}

		std::string toId = edgePair.second->toJunctionId;
		if (toId.empty())
		{
			continue;
		}
		PathfinderJunction *from = junctions[fromId];
		ASSERT(from);
		PathfinderJunction *to = junctions[toId];
		ASSERT(to);
		edgePair.second->fromJunction = from;
		edgePair.second->toJunction = to;
	}
	EV << "Parhfinder initialized!\n";
}
void Pathfinder::finish()
{

}

int Pathfinder::numInitStages() const
{
	return 1;
}

std::list<std::string> Pathfinder::generateRandomRouteStr(const std::string &startEdgeId,
		const std::set<std::string> &disallowedEdges, double minDistance, uint64_t maxEdges) const
{

	std::vector<std::string> disallowedEdgesVec;
	for (std::string edgeId : disallowedEdges)
	{
		disallowedEdgesVec.push_back(edgeId);
	}

	return generateRandomRouteStr(startEdgeId, disallowedEdgesVec, minDistance, maxEdges);
}

std::list<std::string> Pathfinder::generateRandomRouteStr(const std::string &startEdgeId,
		const std::vector<std::string> &disallowedEdges, double minDistance, uint64_t maxEdges) const
{

	std::list<std::string> route;
	std::list<PathfinderEdge*> randomEdges = generateRandomRoute(startEdgeId, disallowedEdges, minDistance, maxEdges);

	for (PathfinderEdge *edge : randomEdges)
	{
		route.push_back(edge->id);
	}

	return route;
}

PathfinderEdge* Pathfinder::getNextRandomEdge(PathfinderEdge *currentEdge,
		const std::vector<std::string> &disallowedEdges) const
{

	std::vector<PathfinderEdge*> possibleEdges;

	std::vector<PathfinderEdge*> visited;
	std::vector<PathfinderEdge*> stack;

	for (PathfinderEdge *edge : currentEdge->connectedEdges)
	{
		if (!edge->isInternal)
		{
			if (!vecContains(disallowedEdges, edge->id))
			{
				possibleEdges.push_back(edge);
			}
		}
		else
		{
			stack.push_back(edge);
		}
	}

	while (stack.size() > 0)
	{
		PathfinderEdge *internalEdge = stack.back();
		stack.pop_back();
		visited.push_back(internalEdge);
		for (PathfinderEdge *edge : internalEdge->connectedEdges)
		{
			if (!edge->isInternal)
			{
				if (!vecContains(disallowedEdges, edge->id))
				{
					possibleEdges.push_back(edge);
				}
			}
			else
			{
				if (!vecContains(visited, internalEdge))
				{
					stack.push_back(edge);
				}
			}
		}
	}

	if (possibleEdges.size() == 0)
	{
		return nullptr;
	}

	int randomIndex = intuniform(0, possibleEdges.size() - 1);
	return possibleEdges[randomIndex];

}

std::list<PathfinderEdge*> Pathfinder::generateRandomRoute(const std::string &startEdgeId,
		const std::vector<std::string> &disallowedEdges, double minDistance, uint64_t maxEdges) const
{
	std::list<PathfinderEdge*> res;
	PathfinderEdge *startEdge = edges.at(startEdgeId);
	double totalDistance = 0;

	PathfinderEdge *currentEdge = startEdge;

	while (totalDistance < minDistance && res.size() < maxEdges)
	{
		PathfinderEdge *nextEdge = getNextRandomEdge(currentEdge, disallowedEdges);
		ASSERT(nextEdge);
		totalDistance += nextEdge->getLengthTraci();
		res.push_back(nextEdge);
		currentEdge = nextEdge;
	}

	return res;
}

