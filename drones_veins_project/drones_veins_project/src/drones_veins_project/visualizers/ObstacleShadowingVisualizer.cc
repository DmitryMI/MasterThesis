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

#include "ObstacleShadowingVisualizer.h"

using namespace drones_veins_project;

#include <osg/Group>
#include <osg/Material>
#include <osg/Geometry>
#include <osg/LineWidth>
#include <osg/Shape>
#include <osg/ShapeDrawable>
#include <string>
#include "veins/base/utils/FindModule.h"
#include "veins/base/modules/BaseWorldUtility.h"
#include "OsvTimeoutMessage_m.h"

Define_Module(drones_veins_project::ObstacleShadowingVisualizer);

ObstacleShadowingVisualizer::ObstacleShadowingVisualizer()
{
	// TODO Auto-generated constructor stub

}

ObstacleShadowingVisualizer::~ObstacleShadowingVisualizer()
{
	// TODO Auto-generated destructor stub
}

void ObstacleShadowingVisualizer::initialize(int stage)
{
	cModule::initialize(stage);

	if (stage == 0)
	{
		osgFlipY = par("osgFlipY").boolValue();
	}
}

void ObstacleShadowingVisualizer::handleMessage(omnetpp::cMessage *msg)
{
	if (OsvTimeoutMessage *timeoutMessage = dynamic_cast<OsvTimeoutMessage*>(msg))
	{
		std::string name = timeoutMessage->getDisplayGroupName();
		for (int i = 0; i < displayGroups.size(); i++)
		{
			if (displayGroups[i].get()->getName() == name)
			{
				osg::ref_ptr<osg::Group> group = displayGroups[i];
				cOsgCanvas *canvas = getParentModule()->getOsgCanvas();
				osg::Group *scene = dynamic_cast<osg::Group*>(canvas->getScene());
				ASSERT(scene);
				scene->removeChild(group);

				displayGroups.erase(displayGroups.begin(), displayGroups.begin() + i);
				break;
			}
		}
	}
}

osg::ref_ptr<osg::StateSet> ObstacleShadowingVisualizer::createLineStateSet(const osg::Vec4 &color)
{
	osg::ref_ptr<osg::Material> lineMaterial = new osg::Material();
	lineMaterial->setAmbient(osg::Material::FRONT_AND_BACK, color);
	lineMaterial->setDiffuse(osg::Material::FRONT_AND_BACK, color);
	osg::ref_ptr<osg::StateSet> stateSet = new osg::StateSet();
	osg::ref_ptr<osg::LineWidth> lineWidth = new osg::LineWidth();
	lineWidth->setWidth(par("lineWidth").doubleValue());
	stateSet->setAttribute(lineWidth);
	stateSet->setAttribute(lineMaterial);
	stateSet->setMode(GL_LIGHTING, osg::StateAttribute::OFF);
	return stateSet;
}

osg::ref_ptr<osg::StateSet> ObstacleShadowingVisualizer::createShapeStateSet(const osg::Vec4 &color)
{
	osg::ref_ptr<osg::Material> shapeMaterial = new osg::Material();
	osg::Vec4 shapeColorVec(1.0, 0, 0.0, 1.0);
	shapeMaterial->setAmbient(osg::Material::FRONT_AND_BACK, color);
	shapeMaterial->setDiffuse(osg::Material::FRONT_AND_BACK, color);
	osg::ref_ptr<osg::StateSet> stateSet = new osg::StateSet();
	stateSet->setAttribute(shapeMaterial);
	stateSet->setMode(GL_LIGHTING, osg::StateAttribute::OFF);
	return stateSet;
}

osg::ref_ptr<osg::Geode> ObstacleShadowingVisualizer::createSphere(const osg::Vec3 &pos, double radius,
		osg::Vec4 &colorVec)
{
	osg::ref_ptr<osg::Geode> shapeGeode = new osg::Geode();
	osg::ref_ptr<osg::ShapeDrawable> shapeDrawable = new osg::ShapeDrawable();
	osg::ref_ptr<osg::Sphere> sphere = new osg::Sphere(pos, radius);
	shapeDrawable->setShape(sphere);
	shapeDrawable->setColor(colorVec);
	shapeGeode->addDrawable(shapeDrawable);

	return shapeGeode;
}

osg::ref_ptr<osg::Geode> ObstacleShadowingVisualizer::createLine(const osg::Vec3 &from, const osg::Vec3 &to)
{
	osg::ref_ptr<osg::Geode> lineGeode = new osg::Geode();

	osg::ref_ptr<osg::Vec3Array> lineVerts = new osg::Vec3Array();
	lineVerts->push_back(from);
	lineVerts->push_back(to);

	osg::ref_ptr<osg::DrawArrays> primitiveSet = new osg::DrawArrays(osg::PrimitiveSet::LINES);
	primitiveSet->setFirst(0);
	primitiveSet->setCount(lineVerts->size());

	osg::ref_ptr<osg::Geometry> geometry = new osg::Geometry();
	geometry->setVertexArray(lineVerts);
	geometry->addPrimitiveSet(primitiveSet);

	lineGeode->addDrawable(geometry);

	return lineGeode;
}

void ObstacleShadowingVisualizer::visualizeIntersections(
		const std::vector<std::pair<veins::Obstacle*, std::vector<double>>> &intersections,
		const veins::Coord &senderPos, const veins::Coord &receiverPos)
{
	Enter_Method_Silent();

	veins::Coord senderPosMod = senderPos;
	veins::Coord receiverPosMod = receiverPos;

	if (osgFlipY)
	{
		veins::BaseWorldUtility *world = veins::FindModule<veins::BaseWorldUtility*>::findGlobalModule();
		ASSERT(world);
		senderPosMod.y = world->getPgs()->y - senderPosMod.y;
		receiverPosMod.y = world->getPgs()->y - receiverPosMod.y;
	}

	cOsgCanvas *canvas = getParentModule()->getOsgCanvas();
	osg::Group *scene = dynamic_cast<osg::Group*>(canvas->getScene());
	ASSERT(scene);

	osg::ref_ptr<osg::Group> group = new osg::Group();
	osg::ref_ptr<osg::Geode> losGeode = createLine(osg::Vec3(senderPosMod.x, senderPosMod.y, senderPosMod.z),
			osg::Vec3(receiverPosMod.x, receiverPosMod.y, receiverPosMod.z));

	std::string losColorStr = par("lineColor").stringValue();
	auto losColor = cFigure::Color(losColorStr.c_str());
	auto losColorVec = osg::Vec4(losColor.red / 255, losColor.green / 255, losColor.blue / 255, 1);
	auto losStateSet = createLineStateSet(losColorVec);
	losGeode->setStateSet(losStateSet);
	group->addChild(losGeode);

	std::string shapeColorStr = par("shapeColor").stringValue();
	auto shapeColor = cFigure::Color(shapeColorStr.c_str());
	auto shapeColorVec = osg::Vec4(shapeColor.red / 255, shapeColor.green / 255, shapeColor.blue / 255, 1);
	auto shapeStateSet = createShapeStateSet(shapeColorVec);

	double dx = receiverPosMod.x - senderPosMod.x;
	double dy = receiverPosMod.y - senderPosMod.y;
	double dz = receiverPosMod.z - senderPosMod.z;
	double radius = par("sphereRadius").doubleValue();
	for (const auto &obstacleIntersections : intersections)
	{
		std::vector<double> intersectionPoints = obstacleIntersections.second;
		for (double pointFactor : intersectionPoints)
		{
			double x = senderPosMod.x + pointFactor * dx;
			double y = senderPosMod.y + pointFactor * dy;
			double z = senderPosMod.z + pointFactor * dz;
			osg::ref_ptr<osg::Geode> sphereGeode = createSphere(osg::Vec3(x, y, z), radius, shapeColorVec);
			sphereGeode->setStateSet(shapeStateSet);
			group->addChild(sphereGeode);
		}

	}

	scene->addChild(group);
	displayGroups.push_back(group);

	std::string groupName = std::to_string(displayGroupCounter);
	displayGroupCounter++;
	group->setName(groupName);

	OsvTimeoutMessage *timeoutMessage = new OsvTimeoutMessage();
	timeoutMessage->setDisplayGroupName(groupName.c_str());
	scheduleAt(simTime() + par("duration").doubleValue(), timeoutMessage);
}
