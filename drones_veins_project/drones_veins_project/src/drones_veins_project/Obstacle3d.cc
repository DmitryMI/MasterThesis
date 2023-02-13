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

osg::Geode* Obstacle3d::createWall(int wallIndex1, int wallIndex2)
{
	Coord coord1 = coords[wallIndex1];
	Coord coord2 = coords[wallIndex2];

	auto verts = new osg::Vec3Array();
	verts->push_back(osg::Vec3(coord1.x, coord1.y, 0));
	verts->push_back(osg::Vec3(coord2.x, coord2.y, 0));
	verts->push_back(osg::Vec3(coord2.x, coord2.y, height));
	verts->push_back(osg::Vec3(coord1.x, coord1.y, height));

	auto primitiveSet = new osg::DrawArrays(osg::PrimitiveSet::POLYGON);
	primitiveSet->setFirst(0);
	primitiveSet->setCount(verts->size());

	auto geometry = new osg::Geometry();
	geometry->setVertexArray(verts);
	geometry->addPrimitiveSet(primitiveSet);
	auto geode = new osg::Geode();
	geode->addDrawable(geometry);

	return geode;
}

osg::Geode* Obstacle3d::createHorizontalPolygon(float height)
{
	auto verts = new osg::Vec3Array();
	for (auto &coord : coords)
	{
		verts->push_back(osg::Vec3(coord.x, coord.y, height));
	}

	auto primitiveSet = new osg::DrawArrays(osg::PrimitiveSet::POLYGON);
	primitiveSet->setFirst(0);
	primitiveSet->setCount(verts->size());

	auto geometry = new osg::Geometry();
	geometry->setVertexArray(verts);
	geometry->addPrimitiveSet(primitiveSet);
	auto geode = new osg::Geode();
	geode->addDrawable(geometry);

	return geode;
}

void Obstacle3d::createOsgGeometry(const cFigure::Color &color)
{

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

		osg::Geode *wall = createWall(i, j);
		osgNode->addChild(wall);
	}

	osg::Geode *polyFloor = createHorizontalPolygon(0);
	osgNode->addChild(polyFloor);
	osg::Geode *polyCeil = createHorizontalPolygon(height);
	osgNode->addChild(polyCeil);

	auto material = new osg::Material();
	osg::Vec4 colorVec(color.red / 255.0, color.green / 255.0, color.blue / 255.0, 1.0);
	material->setAmbient(osg::Material::FRONT_AND_BACK, colorVec);
	material->setDiffuse(osg::Material::FRONT_AND_BACK, colorVec);
	auto stateSet = new osg::StateSet();

	auto lineWidth = new osg::LineWidth();
	lineWidth->setWidth(3);
	stateSet->setAttribute(lineWidth);

	stateSet->setAttribute(material);
	osg::ShadeModel* shadeModel = new osg::ShadeModel();
	shadeModel->setMode(osg::ShadeModel::Mode::FLAT);
	stateSet->setAttribute(shadeModel);
	//stateSet->setMode(GL_LIGHTING, osg::StateAttribute::OFF);

	osgNode->setStateSet(stateSet);
}

#ifdef WITH_OSG

void Obstacle3d::drawOnOsgCanvas(cOsgCanvas *canvas, std::string &colorStr)
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

	createOsgGeometry(color);

	scene->addChild(osgNode);
#endif
}
