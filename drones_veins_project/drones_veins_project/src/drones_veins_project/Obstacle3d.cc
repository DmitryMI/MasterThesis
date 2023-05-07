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

#include "Obstacle3d.h"
#include <vector>
#include <algorithm>
#include "veins/base/utils/FindModule.h"
#include "veins/base/modules/BaseWorldUtility.h"

#ifdef WITH_OSG
#include "veins/base/utils/FindModule.h"
#include <osg/ShadeModel>
#endif

using namespace veins;
using namespace drones_veins_project;

Obstacle3d::Obstacle3d(std::string id, std::string type, double attenuationPerCut, double attenuationPerMeter,
		double height) :
		Obstacle(id, type, attenuationPerCut, attenuationPerMeter)
{
	this->height = height;
}

Obstacle3d::~Obstacle3d()
{

}

bool Obstacle3d::containsPoint(veins::Coord Point) const
{
	//return Obstacle::containsPoint(Point);
	return Obstacle::containsPoint(Point) && Point.z >= 0 && Point.z <= height;
}

bool Obstacle3d::getLineToLineIntersection(const veins::Coord &line1Start, const veins::Coord &line1End,
		const veins::Coord &line2Start, const veins::Coord &line2End, veins::Coord &outIntersection) const
{
	float x1 = line1Start.x;
	float y1 = line1Start.y;
	float x2 = line1End.x;
	float y2 = line1End.y;

	float x3 = line2Start.x;
	float y3 = line2Start.y;
	float x4 = line2End.x;
	float y4 = line2End.y;

	float th = (x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4);
	float tl = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	float t = th / tl;

	float uh = (x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2);
	float ul = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	float u = uh / ul;

	if (!(0 <= t && t <= 1) || !(0 <= u && u <= 1))
	{
		return false;
	}

	float x = x1 + t * (x2 - x1);
	float y = y1 + t * (y2 - y1);

	outIntersection.x = x;
	outIntersection.y = y;
	return true;
}

bool Obstacle3d::getWallIntersection(const veins::Coord &lineStart, const veins::Coord &lineEnd, int wallStartIndex,
		int wallEndIndex, veins::Coord &intersectionPoint) const
{
	// EV << "getWallIntersection(S(" << lineStart.x << ", " << lineStart.y << ", " << lineStart.z << "), E(" << lineEnd.x
	// 		<< ", " << lineEnd.y << ", " << lineEnd.z << ")) " << "W(" << wallStartIndex << ", " << wallEndIndex << ")"
	//		<< "\n";

	veins::Coord wallStart = coords[wallStartIndex];
	veins::Coord wallEnd = coords[wallEndIndex];

	// EV << "Wall S: " << wallStart.x << ", " << wallStart.y << ", " << wallStart.z << "\n";
	// EV << "Wall E: " << wallEnd.x << ", " << wallEnd.y << ", " << wallEnd.z << "\n";

	veins::Coord xyIntersection;

	if (!getLineToLineIntersection(lineStart, lineEnd, wallStart, wallEnd, xyIntersection))
	{
		return false;
	}

	float k;
	if (lineEnd.x == lineStart.x)
	{
		k = (xyIntersection.y - lineStart.y) / (lineEnd.y - lineStart.y);
	}
	else
	{
		k = (xyIntersection.x - lineStart.x) / (lineEnd.x - lineStart.x);
	}

	float intersectionZ = lineStart.z + k * (lineEnd.z - lineStart.z);

	if (0 <= intersectionZ && intersectionZ <= height)
	{
		intersectionPoint.x = xyIntersection.x;
		intersectionPoint.y = xyIntersection.y;
		intersectionPoint.z = intersectionZ;
		return true;
	}

	return false;
}

void Obstacle3d::getWallIntersections(const veins::Coord &lineStart, const veins::Coord &lineEnd,
		std::vector<veins::Coord> &outIntersections) const
{
	// EV << "getWallIntersections(S(" << lineStart.x << ", " << lineStart.y << ", " << lineStart.z << "), E(" << lineEnd.x
	//		<< ", " << lineEnd.y << ", " << lineEnd.z << "))\n";

	veins::Coord intersectionPoint;
	int coords_size = (int) coords.size();

	// EV << "coords_size == " << coords_size << "\n";
	for (int i = 0; i < coords_size - 1; i++)
	{
		if (!getWallIntersection(lineStart, lineEnd, i, i + 1, intersectionPoint))
		{
			continue;
		}
		// EV << "Intersection found with wall (" << i << ", " << i + 1 << ") at (" << intersectionPoint.x << ", "
				<< intersectionPoint.y << ", " << intersectionPoint.z << ")\n";

		if (std::find(outIntersections.begin(), outIntersections.end(), intersectionPoint) != outIntersections.end())
		{
			EV << "Found duplicate intersection, probably the line goes exactly through a corner. Dropped.\n";
		}
		else
		{
			outIntersections.push_back(intersectionPoint);
		}

	}
	// EV << "Found " << outIntersections.size() << " intersections with walls\n";
}

bool Obstacle3d::getHorizonToLineIntersection(const veins::Coord &lineStart, const veins::Coord &lineEnd,
		float horizonY, veins::Coord &outIntersection) const
{
	if (lineStart.y == lineEnd.y)
	{
		return false;
	}

	float k = (horizonY - lineStart.y) / (lineEnd.y - lineStart.y);
	if (k < 0 || k > 1)
	{
		return false;
	}

	float x = lineStart.x + k * (lineEnd.x - lineStart.x);
	outIntersection.x = x;
	outIntersection.y = horizonY;
	return true;
}

bool Obstacle3d::getHorizontalIntersection(const veins::Coord &lineStart, const veins::Coord &lineEnd,
		float intersectionZ, veins::Coord &intersectionPoint) const
{
	if (lineEnd.z == lineStart.z)
	{
		return false;
	}

	float k = (intersectionZ - lineStart.z) / (lineEnd.z - lineStart.z);
	if (k < 0 || k > 1)
	{
		return false;
	}

	float x = lineStart.x + k * (lineEnd.x - lineStart.x);
	float y = lineStart.y + k * (lineEnd.y - lineStart.y);

	int intersectionCount = 0;
	for (int i = 0; i < coords.size() - 1; i++)
	{
		veins::Coord edgeStart = coords[i];
		veins::Coord edgeEnd = coords[i + 1];

		veins::Coord edgeIntersection;
		if (getHorizonToLineIntersection(edgeStart, edgeEnd, y, edgeIntersection))
		{
			if (edgeIntersection.x > x)
			{
				intersectionCount++;
			}
		}
	}
	intersectionPoint.x = x;
	intersectionPoint.y = y;
	intersectionPoint.z = intersectionZ;

	return intersectionCount % 2 == 1;
}

void Obstacle3d::getIntersectionPoints(const veins::Coord &lineStart, const veins::Coord &lineEnd,
		std::vector<veins::Coord> &outIntersections) const
{
	if (coords.size() < 2)
	{
		return;
	}

	getWallIntersections(lineStart, lineEnd, outIntersections);

	veins::Coord floorIntersection;
	veins::Coord ceilingIntersection;
	if (getHorizontalIntersection(lineStart, lineEnd, 0, floorIntersection))
	{
		// EV << "Found floor intersection" << "\n";
		if (std::find(outIntersections.begin(), outIntersections.end(), floorIntersection) != outIntersections.end())
		{
			EV << "Found duplicate intersection, probably the line goes exactly through a corner. Dropped.\n";
		}
		else
		{
			outIntersections.push_back(floorIntersection);
		}
	}
	if (getHorizontalIntersection(lineStart, lineEnd, height, ceilingIntersection))
	{
		// EV << "Found ceiling intersection" << "\n";
		if (std::find(outIntersections.begin(), outIntersections.end(), ceilingIntersection) != outIntersections.end())
		{
			EV << "Found duplicate intersection, probably the line goes exactly through a corner. Dropped.\n";
		}
		else
		{
			outIntersections.push_back(ceilingIntersection);
		}
	}

	ASSERT(outIntersections.size() % 2 == 0);
}

std::vector<double> Obstacle3d::getIntersections(const Coord &senderPos, const Coord &receiverPos) const
{
	//return Obstacle::getIntersections(senderPos, receiverPos);

	std::vector < veins::Coord > intersectionPoints;

	getIntersectionPoints(senderPos, receiverPos, intersectionPoints);

	std::vector<double> intersectionFactors;
	for (const veins::Coord &intersectionPoint : intersectionPoints)
	{
		double k;
		if (receiverPos.x != senderPos.x)
		{
			k = (intersectionPoint.x - senderPos.x) / (receiverPos.x - senderPos.x);
		}
		else if (receiverPos.y != senderPos.y)
		{
			k = (intersectionPoint.y - senderPos.y) / (receiverPos.y - senderPos.y);
		}
		else
		{
			k = (intersectionPoint.z - senderPos.z) / (receiverPos.z - senderPos.z);
		}
		intersectionFactors.push_back(k);
	}
	std::sort(intersectionFactors.begin(), intersectionFactors.end());
	if (intersectionFactors.size() == 1)
	{
		intersectionFactors.push_back(intersectionFactors[0]);
	}

	ASSERT(intersectionFactors.size() % 2 == 0);
	return intersectionFactors;
}

#ifdef WITH_OSG

osg::Geode* Obstacle3d::createWall(int wallIndex1, int wallIndex2, osg::PrimitiveSet::Mode mode, bool osgFlipY)
{
	Coord coord1 = coords[wallIndex1];
	Coord coord2 = coords[wallIndex2];

	auto verts = new osg::Vec3Array();

	if (!osgFlipY)
	{
		verts->push_back(osg::Vec3(coord1.x, coord1.y, 0));
		verts->push_back(osg::Vec3(coord2.x, coord2.y, 0));
		verts->push_back(osg::Vec3(coord2.x, coord2.y, height));
		verts->push_back(osg::Vec3(coord1.x, coord1.y, height));
	}
	else
	{
		veins::BaseWorldUtility *world = veins::FindModule<veins::BaseWorldUtility*>::findGlobalModule();
		ASSERT(world);
		verts->push_back(osg::Vec3(coord1.x, world->getPgs()->y - coord1.y, 0));
		verts->push_back(osg::Vec3(coord2.x, world->getPgs()->y - coord2.y, 0));
		verts->push_back(osg::Vec3(coord2.x, world->getPgs()->y - coord2.y, height));
		verts->push_back(osg::Vec3(coord1.x, world->getPgs()->y - coord1.y, height));
	}

	auto primitiveSet = new osg::DrawArrays(mode);
	primitiveSet->setFirst(0);
	primitiveSet->setCount(verts->size());

	auto geometry = new osg::Geometry();
	geometry->setVertexArray(verts);
	geometry->addPrimitiveSet(primitiveSet);
	auto geode = new osg::Geode();
	geode->addDrawable(geometry);

	return geode;
}

osg::Geode* Obstacle3d::createHorizontalPolygon(float height, osg::PrimitiveSet::Mode mode, bool osgFlipY)
{
	auto verts = new osg::Vec3Array();

	if (!osgFlipY)
	{
		for (auto &coord : coords)
		{
			verts->push_back(osg::Vec3(coord.x, coord.y, height));
		}
	}
	else
	{
		veins::BaseWorldUtility *world = veins::FindModule<veins::BaseWorldUtility*>::findGlobalModule();
		ASSERT(world);
		for (auto &coord : coords)
		{
			verts->push_back(osg::Vec3(coord.x, world->getPgs()->y - coord.y, height));
		}
	}

	auto primitiveSet = new osg::DrawArrays(mode);
	primitiveSet->setFirst(0);
	primitiveSet->setCount(verts->size());

	auto geometry = new osg::Geometry();
	geometry->setVertexArray(verts);
	geometry->addPrimitiveSet(primitiveSet);
	auto geode = new osg::Geode();
	geode->addDrawable(geometry);

	return geode;
}

void Obstacle3d::createOsgGeometry(const cFigure::Color &color, bool obstaclesShadingEnabled, bool wireframeModeEnabled,
		bool osgFlipY)
{
	auto borderMaterial = new osg::Material();
	osg::Vec4 borderColorVec(0, 0, 0, 1.0);
	borderMaterial->setAmbient(osg::Material::FRONT_AND_BACK, borderColorVec);
	borderMaterial->setDiffuse(osg::Material::FRONT_AND_BACK, borderColorVec);
	auto borderStateSet = new osg::StateSet();
	auto lineWidth = new osg::LineWidth();
	lineWidth->setWidth(3);
	borderStateSet->setAttribute(lineWidth);
	borderStateSet->setAttribute(borderMaterial);
	borderStateSet->setMode(GL_LIGHTING, osg::StateAttribute::OFF);

	auto polygonMaterial = new osg::Material();
	osg::Vec4 polygonColorVec(color.red / 255.0, color.green / 255.0, color.blue / 255.0, 1.0);
	polygonMaterial->setAmbient(osg::Material::FRONT_AND_BACK, polygonColorVec);
	polygonMaterial->setDiffuse(osg::Material::FRONT_AND_BACK, polygonColorVec);
	auto polygonStateSet = new osg::StateSet();
	polygonStateSet->setAttribute(polygonMaterial);
	if (obstaclesShadingEnabled)
	{
		osg::ShadeModel *shadeModel = new osg::ShadeModel();
		shadeModel->setMode(osg::ShadeModel::Mode::FLAT);
		polygonStateSet->setAttribute(shadeModel);
	}
	else
	{
		polygonStateSet->setMode(GL_LIGHTING, osg::StateAttribute::OFF);
	}

	for (int i = 0; i < coords.size(); i++)
	{
		int j;
		if (i == coords.size() - 1)
		{
			j = 0;
		}
		else
		{
			j = i + 1;
		}

		if (!wireframeModeEnabled)
		{
			osg::Geode *wall = createWall(i, j, osg::PrimitiveSet::POLYGON, osgFlipY);
			wall->setStateSet(polygonStateSet);
			osgNode->addChild(wall);
		}
		osg::Geode *wallBorder = createWall(i, j, osg::PrimitiveSet::LINE_LOOP, osgFlipY);
		wallBorder->setStateSet(borderStateSet);
		osgNode->addChild(wallBorder);
	}

	if (!wireframeModeEnabled)
	{
		osg::Geode *polyFloor = createHorizontalPolygon(0, osg::PrimitiveSet::POLYGON, osgFlipY);
		polyFloor->setStateSet(polygonStateSet);
		osgNode->addChild(polyFloor);
	}

	osg::Geode *polyFloorBorder = createHorizontalPolygon(0, osg::PrimitiveSet::LINES, osgFlipY);
	polyFloorBorder->setStateSet(borderStateSet);
	osgNode->addChild(polyFloorBorder);

	if (!wireframeModeEnabled)
	{
		osg::Geode *polyCeil = createHorizontalPolygon(height, osg::PrimitiveSet::POLYGON, osgFlipY);
		polyCeil->setStateSet(polygonStateSet);
		osgNode->addChild(polyCeil);
	}

	osg::Geode *polyCeilBorder = createHorizontalPolygon(height, osg::PrimitiveSet::LINES, osgFlipY);
	polyCeilBorder->setStateSet(borderStateSet);
	osgNode->addChild(polyCeilBorder);
}

void Obstacle3d::drawOnOsgCanvas(cOsgCanvas *canvas, std::string &colorStr, bool obstaclesShadingEnabled,
		bool wireframeModeEnabled, bool osgFlipY)
{
	ASSERT(canvas);

	osg::Group *scene = dynamic_cast<osg::Group*>(canvas->getScene());
	if (!scene)
	{
		scene = new osg::Group();
		canvas->setScene(scene);
	}
	ASSERT(scene);

	osgNode = new osg::Group();

	auto color = cFigure::Color(colorStr.c_str());

	createOsgGeometry(color, obstaclesShadingEnabled, wireframeModeEnabled, osgFlipY);

	scene->addChild(osgNode);
}
#endif
