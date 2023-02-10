// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "GameFramework/SpringArmComponent.h"
#include "Obstacle3d.generated.h"

UCLASS()
class OBSTACLE3DDEMO_API AObstacle3d : public AActor
{
	GENERATED_BODY()

private:
	UPROPERTY(EditAnywhere)
	TArray<FVector2f> shapeCoords;

	UPROPERTY(EditAnywhere)
	float height;	


protected:
	virtual void BeginPlay() override;

	void DrawObstacleWall(int index1, int index2);
	void DrawObstracle();

	static bool GetLineToLineIntersection(const FVector2f& line1Start, const FVector2f& line1End, const FVector2f& line2Start, const FVector2f& line2End, FVector2f& outIntersection);
	static bool GetHorizonToLineIntersection(const FVector2f& lineStart, const FVector2f& lineEnd, float horizonY, FVector2f& outIntersection);

	bool GetWallIntersection(const FVector& lineStart, const FVector& lineEnd, int wallStartIndex, int wallEndIndex, FVector& intersectionPoint);

	void GetWallIntersections(const FVector& lineStart, const FVector& lineEnd, TArray<FVector>& outIntersections);
	
	bool GetHorizontalIntersection(const FVector& lineStart, const FVector& lineEnd, float intersectionZ, FVector& intersectionPoint);

public:	
	float GetScaledHeight();

	AObstacle3d();
	virtual void Tick(float DeltaTime) override;

	void GetIntersections(const FVector& lineStart, const FVector& lineEnd, TArray<FVector>& outIntersections);

};
