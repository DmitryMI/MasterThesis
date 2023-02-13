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

#include "NodeOsgVisualizer.h"

#define _USE_MATH_DEFINES
#include <math.h>

#ifdef WITH_OSG
#include <osg/Geode>
#include <osg/Geometry>
#include <osg/Group>
#include <osg/LineWidth>
#include <osg/Material>
#include <osg/ShapeDrawable>
#include <osg/Matrix>
#include <osg/MatrixTransform>
#include <osgDB/ReadFile>
#include "veins/base/utils/FindModule.h"
#include "veins/base/modules/BaseMobility.h"
#include "veins/modules/mobility/traci/TraCIScenarioManager.h"
#include "veins/modules/mobility/traci/TraCIMobility.h"
#include <string>
#include <unistd.h>
#endif

using namespace veins;
using namespace drones_veins_project;

Define_Module(drones_veins_project::NodeOsgVisualizer);

NodeOsgVisualizer::NodeOsgVisualizer()
{
	// TODO Auto-generated constructor stub

}

NodeOsgVisualizer::~NodeOsgVisualizer()
{

}

#ifdef WITH_OSG
void NodeOsgVisualizer::initialize(int stage)
{
	cModule::initialize(stage);
	if (stage == 0)
	{
		cModule *parent = getParentModule();
		cModule *root = this;
		while (parent != nullptr)
		{
			root = parent;
			parent = root->getParentModule();
		}

		cOsgCanvas *canvas = root->getOsgCanvas();
		ASSERT(canvas);
		osg::Group *scene = dynamic_cast<osg::Group*>(canvas->getScene());
		if (!scene)
		{
			scene = new osg::Group();
			canvas->setScene(scene);
		}
		ASSERT(scene);

		osgTransform = new osg::MatrixTransform();
		scene->addChild(osgTransform);

		osgGeode = new osg::Geode();
		osgTransform->addChild(osgGeode);

		auto color = cFigure::Color(par("color").stringValue());
		osg::Vec4 colorVec(color.red / 255.0, color.green / 255.0, color.blue / 255.0, 1.0);

		initDrawables(colorVec);

		auto material = new osg::Material();
		material->setAmbient(osg::Material::FRONT_AND_BACK, colorVec);
		material->setDiffuse(osg::Material::FRONT_AND_BACK, colorVec);

		auto lineWidth = new osg::LineWidth();
		lineWidth->setWidth(par("lineWidth").doubleValue());

		auto stateSet = new osg::StateSet();
		stateSet->setAttribute(material);
		stateSet->setMode(GL_LIGHTING, osg::StateAttribute::OFF);
		stateSet->setAttribute(lineWidth);
		osgGeode->setStateSet(stateSet);

		//std::string updaterSignal = par("updaterSignal").str();
		//subscribe(updaterSignal.c_str(), this);
		veins::BaseMobility *mobility = veins::FindModule<veins::BaseMobility*>::findSubModule(getParentModule());
		if (mobility)
		{
			mobility->subscribe(veins::BaseMobility::mobilityStateChangedSignal, this);
		}

	}
}

void NodeOsgVisualizer::initDrawables(osg::Vec4 colorVec)
{
	std::string modelPath = par("modelPath").stringValue();
	if (modelPath.empty())
	{
		osg::ShapeDrawable *shapeDrawable = new osg::ShapeDrawable();
		osg::Shape *boxShape = new osg::Box(osg::Vec3(0.0f, 0.0f, 0.0f), 10.0f, 6.0f, 2.0f);
		shapeDrawable->setShape(boxShape);
		shapeDrawable->setColor(colorVec);

		osgGeode->addDrawable(shapeDrawable);
	}
	else
	{
		osg::ref_ptr<osg::Node> model = osgDB::readNodeFile(modelPath);
		ASSERT(model);
		osgGeode->addChild(model);
	}
}

void NodeOsgVisualizer::receiveSignal(cComponent *source, simsignal_t signalID, cObject *obj, cObject *details)
{
	Enter_Method_Silent();

	veins::BaseMobility *mobility = veins::FindModule<veins::BaseMobility*>::findSubModule(getParentModule());
	if (!mobility)
	{
		return;
	}

	Coord location = mobility->getPositionAt(simTime());
	float angleRadZ = 0;
	if (veins::TraCIMobility *traci = dynamic_cast<veins::TraCIMobility*>(mobility))
	{
		angleRadZ = traci->getHeading().getRad();
	}
	else
	{
		Coord orientation = mobility->getCurrentOrientation();
		double zAngleDeg = atan2(orientation.y, orientation.x);
		angleRadZ = zAngleDeg * M_PI / 180;
	}
	setTransform(location, angleRadZ);
}

void NodeOsgVisualizer::setTransform(const veins::Coord &location, double angleZ)
{
	osg::Vec3 posVec3(location.x, location.y, location.z);

	const osg::Vec3d axis(0, 0, 1);
	double scale = par("scale").doubleValue();
	auto matrixScale = osg::Matrix::scale(osg::Vec3(scale, scale, scale));
	auto matrixTranslate = osg::Matrix::translate(posVec3);
	auto matrixRotate = osg::Matrix::rotate(angleZ, axis);
	auto matrix = matrixScale * matrixRotate * matrixTranslate;
	osgTransform->setMatrix(matrix);
}

#else
void NodeOsgVisualizer::setTransform(const veins::Coord &location, double angleZ)
{

}

void NodeOsgVisualizer::receiveSignal(cComponent *source, simsignal_t signalID, cObject *obj, cObject *details)
{

}

#endif
