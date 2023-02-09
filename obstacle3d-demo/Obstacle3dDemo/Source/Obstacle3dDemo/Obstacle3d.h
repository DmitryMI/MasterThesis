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

	UPROPERTY(EditAnywhere)
	float mouseRotationSensitivity = 50.0f;

	UPROPERTY(EditAnywhere)
	float mouseWheelSensitivity = 1000.0f;


protected:
	virtual void BeginPlay() override;

	void DrawObstacleWall(int index1, int index2);
	void DrawObstracle();

	static bool GetLineToLineIntersection(const FVector2f& line1Start, const FVector2f& line1End, const FVector2f& line2Start, const FVector2f& line2End, FVector2f& outIntersection);

	bool GetWallIntersection(const FVector& lineStart, const FVector& lineEnd, int wallStartIndex, int wallEndIndex, FVector& intersectionPoint);

	void GetWallIntersections(const FVector& lineStart, const FVector& lineEnd, TArray<FVector>& outIntersections);
	
public:	
	float GetScaledHeight();

	AObstacle3d();
	virtual void Tick(float DeltaTime) override;

	void GetIntersections(const FVector& lineStart, const FVector& lineEnd, TArray<FVector>& outIntersections);

};
