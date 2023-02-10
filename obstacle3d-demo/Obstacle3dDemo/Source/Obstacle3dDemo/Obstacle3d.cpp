// Fill out your copyright notice in the Description page of Project Settings.


#include "Obstacle3d.h"
#include "DrawDebugHelpers.h"

float AObstacle3d::GetScaledHeight()
{
	return height * GetActorScale().Z;
}

// Sets default values
AObstacle3d::AObstacle3d()
{
	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

// Called when the game starts or when spawned
void AObstacle3d::BeginPlay()
{
	Super::BeginPlay();
}

void AObstacle3d::DrawObstacleWall(int index1, int index2)
{
	FVector location = GetActorLocation();

	FVector shapeCoord1 = FVector(shapeCoords[index1].X, shapeCoords[index1].Y, 0);
	FVector vert1 = location + shapeCoord1 * GetActorScale();
	FVector shapeCoord2 = FVector(shapeCoords[index2].X, shapeCoords[index2].Y, 0);
	FVector vert2 = location + shapeCoord2 * GetActorScale();

	vert1.Z -= GetScaledHeight() / 2;
	vert2.Z -= GetScaledHeight() / 2;

	// Floor
	DrawDebugLine(GetWorld(), vert1, vert2, FColor::Green);
	// Ceiling
	DrawDebugLine(GetWorld(), vert1 + FVector(0, 0, GetScaledHeight()), vert2 + FVector(0, 0, GetScaledHeight()), FColor::Green);

	// Vertical lines	
	DrawDebugLine(GetWorld(), vert1, vert1 + FVector(0, 0, GetScaledHeight()), FColor::Green);
	DrawDebugLine(GetWorld(), vert2, vert2 + FVector(0, 0, GetScaledHeight()), FColor::Green);
}

void AObstacle3d::DrawObstracle()
{
	for (int i = 0; i < shapeCoords.Num() - 1; i++)
	{
		DrawObstacleWall(i, i + 1);
	}
}

bool AObstacle3d::GetLineToLineIntersection(const FVector2f& line1Start, const FVector2f& line1End, const FVector2f& line2Start, const FVector2f& line2End, FVector2f& outIntersection)
{
	float x1 = line1Start.X;
	float y1 = line1Start.Y;
	float x2 = line1End.X;
	float y2 = line1End.Y;

	float x3 = line2Start.X;
	float y3 = line2Start.Y;
	float x4 = line2End.X;
	float y4 = line2End.Y;

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

	outIntersection.X = x;
	outIntersection.Y = y;
	return true;
}

bool AObstacle3d::GetWallIntersection(const FVector& lineStart, const FVector& lineEnd, int wallStartIndex, int wallEndIndex, FVector& intersectionPoint)
{
	FVector location = GetActorLocation();
	FVector2f location2d = FVector2f(location.X, location.Y);

	FVector2f scale2d = FVector2f(GetActorScale().X, GetActorScale().Y);

	FVector2f wallStart = location2d + shapeCoords[wallStartIndex] * scale2d;
	FVector2f wallEnd = location2d + shapeCoords[wallEndIndex] * scale2d;

	// Walls are always vertical rects

	FVector2f xyWallStart = FVector2f(wallStart.X, wallStart.Y);
	FVector2f xyWallEnd = FVector2f(wallEnd.X, wallEnd.Y);
	FVector2f xyLineStart = FVector2f(lineStart.X, lineStart.Y);
	FVector2f xyLineEnd = FVector2f(lineEnd.X, lineEnd.Y);
	FVector2f xyIntersection;

	if (!GetLineToLineIntersection(xyLineStart, xyLineEnd, xyWallStart, xyWallEnd, xyIntersection))
	{
		return false;
	}

	check(lineEnd.X != lineStart.X);
	float k = (xyIntersection.X - lineStart.X) / (lineEnd.X - lineStart.X);
	float intersectionZ = lineStart.Z + k * (lineEnd.Z - lineStart.Z);

	if (location.Z - GetScaledHeight() / 2 <= intersectionZ && intersectionZ <= location.Z + GetScaledHeight() / 2)
	{
		intersectionPoint.X = xyIntersection.X;
		intersectionPoint.Y = xyIntersection.Y;
		intersectionPoint.Z = intersectionZ;
		return true;
	}

	return false;
}

void AObstacle3d::GetWallIntersections(const FVector& lineStart, const FVector& lineEnd, TArray<FVector>& outIntersections)
{
	FVector intersectionPoint;
	for (int i = 0; i < shapeCoords.Num() - 1; i++)
	{
		if (!GetWallIntersection(lineStart, lineEnd, i, i + 1, intersectionPoint))
		{
			continue;
		}
		outIntersections.Add(intersectionPoint);
	}
}

// Called every frame
void AObstacle3d::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	DrawObstracle();
}

void AObstacle3d::GetIntersections(const FVector& lineStart, const FVector& lineEnd, TArray<FVector>& outIntersections)
{
	if (shapeCoords.Num() < 2)
	{
		return;
	}

	// Find intersections with the side walls
	GetWallIntersections(lineStart, lineEnd, outIntersections);
}
