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
	// TODO Check Z
	return Obstacle::containsPoint(Point);
}

std::vector<double> Obstacle3d::getIntersections(const Coord &senderPos, const Coord &receiverPos) const
{
	// TODO Check z
	return Obstacle::getIntersections(senderPos, receiverPos);
}

osg::Geode* Obstacle3d::createWall(int wallIndex1, int wallIndex2, osg::PrimitiveSet::Mode mode)
{
	Coord coord1 = coords[wallIndex1];
	Coord coord2 = coords[wallIndex2];

	auto verts = new osg::Vec3Array();
	verts->push_back(osg::Vec3(coord1.x, coord1.y, 0));
	verts->push_back(osg::Vec3(coord2.x, coord2.y, 0));
	verts->push_back(osg::Vec3(coord2.x, coord2.y, height));
	verts->push_back(osg::Vec3(coord1.x, coord1.y, height));

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

osg::Geode* Obstacle3d::createHorizontalPolygon(float height, osg::PrimitiveSet::Mode mode)
{
	auto verts = new osg::Vec3Array();
	for (auto &coord : coords)
	{
		verts->push_back(osg::Vec3(coord.x, coord.y, height));
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

void Obstacle3d::createOsgGeometry(const cFigure::Color &color, bool obstaclesShadingEnabled, bool wireframeModeEnabled)
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
			osg::Geode *wall = createWall(i, j, osg::PrimitiveSet::POLYGON);
			wall->setStateSet(polygonStateSet);
			osgNode->addChild(wall);
		}
		osg::Geode *wallBorder = createWall(i, j, osg::PrimitiveSet::LINE_LOOP);
		wallBorder->setStateSet(borderStateSet);
		osgNode->addChild(wallBorder);
	}

	if (!wireframeModeEnabled)
	{
		osg::Geode *polyFloor = createHorizontalPolygon(0, osg::PrimitiveSet::POLYGON);
		polyFloor->setStateSet(polygonStateSet);
		osgNode->addChild(polyFloor);
	}

	osg::Geode *polyFloorBorder = createHorizontalPolygon(0, osg::PrimitiveSet::LINES);
	polyFloorBorder->setStateSet(borderStateSet);
	osgNode->addChild(polyFloorBorder);

	if (!wireframeModeEnabled)
	{
		osg::Geode *polyCeil = createHorizontalPolygon(height, osg::PrimitiveSet::POLYGON);
		polyCeil->setStateSet(polygonStateSet);
		osgNode->addChild(polyCeil);
	}

	osg::Geode *polyCeilBorder = createHorizontalPolygon(height, osg::PrimitiveSet::LINES);
	polyCeilBorder->setStateSet(borderStateSet);
	osgNode->addChild(polyCeilBorder);
}

#ifdef WITH_OSG

void Obstacle3d::drawOnOsgCanvas(cOsgCanvas *canvas, std::string &colorStr, bool obstaclesShadingEnabled,
		bool wireframeModeEnabled)
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

	createOsgGeometry(color, obstaclesShadingEnabled, wireframeModeEnabled);

	scene->addChild(osgNode);
#endif
}
