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

#include "ObstacleControl3d.h"
#include <string>

using namespace drones_veins_project;
using namespace veins;

Define_Module(ObstacleControl3d);

ObstacleControl3d::ObstacleControl3d()
{
	// TODO Auto-generated constructor stub

}

ObstacleControl3d::~ObstacleControl3d()
{

}

void ObstacleControl3d::initialize(int stage)
{
	ObstacleControl::initialize(stage);
}

void ObstacleControl3d::add3d(Obstacle3d obstacle3d)
{
	Obstacle3d *o = new Obstacle3d(obstacle3d);
	obstacleOwner.emplace_back(o);

	if (annotations)
	{
		// TODO Print obstacle height
		o->visualRepresentation = annotations->drawPolygon(o->getShape(), "red", annotationGroup);
	}

	cacheEntries.clear();
	isBboxLookupDirty = true;
}

void ObstacleControl3d::add(Obstacle obstacle)
{
	throw cRuntimeError("ObstacleControl3d::add() call detected!");

	double heightDefault = par("buildingsHeightDefault");
	Obstacle3d obstacle3d = Obstacle3d(obstacle.getId(), obstacle.getType(), obstacle.getAttenuationPerCut(),
			obstacle.getAttenuationPerMeter(), heightDefault);
	obstacle3d.setShape(obstacle.getShape());
	add3d(obstacle3d);
}

void ObstacleControl3d::addFromTypeAndShape(std::string id, std::string typeId, std::vector<Coord> shape)
{
	if (!isTypeSupported(typeId))
	{
		throw cRuntimeError("Unsupported obstacle type: \"%s\"", typeId.c_str());
	}
	double heightDefault = par("buildingsHeightDefault");
	Obstacle3d obs(id, typeId, getAttenuationPerCut(typeId), getAttenuationPerMeter(typeId), heightDefault);
	obs.setShape(shape);
	add3d(obs);
}

void ObstacleControl3d::addFromXml(cXMLElement *xml)
{
	std::string rootTag = xml->getTagName();
	if (rootTag != "obstacles")
	{
		throw cRuntimeError("Obstacle definition root tag was \"%s\", but expected \"obstacles\"", rootTag.c_str());
	}

	cXMLElementList list = xml->getChildren();
	for (cXMLElementList::const_iterator i = list.begin(); i != list.end(); ++i)
	{
		cXMLElement *e = *i;

		std::string tag = e->getTagName();

		if (tag == "type")
		{
			// <type id="building" db-per-cut="9" db-per-meter="0.4" />

			ASSERT(e->getAttribute("id"));
			std::string id = e->getAttribute("id");
			ASSERT(e->getAttribute("db-per-cut"));
			std::string perCutParS = e->getAttribute("db-per-cut");
			double perCutPar = strtod(perCutParS.c_str(), nullptr);
			ASSERT(e->getAttribute("db-per-meter"));
			std::string perMeterParS = e->getAttribute("db-per-meter");
			double perMeterPar = strtod(perMeterParS.c_str(), nullptr);

			perCut[id] = perCutPar;
			perMeter[id] = perMeterPar;
		}
		else if (tag == "poly")
		{

			// <poly id="building#0" type="building" color="#F00" shape="16,0 8,13.8564 -8,13.8564 -16,0 -8,-13.8564 8,-13.8564" />
			ASSERT(e->getAttribute("id"));
			std::string id = e->getAttribute("id");
			ASSERT(e->getAttribute("type"));
			std::string type = e->getAttribute("type");
			ASSERT(e->getAttribute("color"));
			std::string color = e->getAttribute("color");
			ASSERT(e->getAttribute("shape"));
			std::string shape = e->getAttribute("shape");

			double height;
			const char *heightAttribute = e->getAttribute("height");
			if (heightAttribute != nullptr)
			{
				height = std::stoi(heightAttribute);
			}
			else
			{
				height = par("buildingsHeightDefault");
			}

			Obstacle3d obs(id, type, getAttenuationPerCut(type), getAttenuationPerMeter(type), height);
			std::vector<Coord> sh;
			cStringTokenizer st(shape.c_str());
			while (st.hasMoreTokens())
			{
				std::string xy = st.nextToken();
				std::vector<double> xya = cStringTokenizer(xy.c_str(), ",").asDoubleVector();
				ASSERT(xya.size() == 2);
				sh.push_back(Coord(xya[0], xya[1]));
			}
			obs.setShape(sh);
			add3d(obs);
		}
		else
		{
			throw cRuntimeError("Found unknown tag in obstacle definition: \"%s\"", tag.c_str());
		}
	}
}

