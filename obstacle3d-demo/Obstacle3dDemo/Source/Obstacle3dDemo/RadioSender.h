// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "RadioReceiver.h"
#include "Obstacle3d.h"
#include "RadioSender.generated.h"

UCLASS()
class OBSTACLE3DDEMO_API ARadioSender : public AActor
{
	GENERATED_BODY()

private:
	UPROPERTY()
	TArray<ARadioReceiver*> radioReceivers;

	UPROPERTY()
	TArray<AObstacle3d*> radioObstacles;

	UPROPERTY(EditAnywhere)
	float movementSpeed = 1000;

	UPROPERTY(EditAnywhere)
	bool bMovementPaused = false;

	FVector nextLocation;

	void DrawLineOfSight(ARadioReceiver* receiver);

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;
	
public:	
	// Sets default values for this actor's properties
	ARadioSender();

	virtual void Tick(float DeltaTime) override;
	UFUNCTION(BlueprintCallable)
	void SetMovementPaused(bool bPaused);
	UFUNCTION(BlueprintCallable)
	bool IsMovementPaused();

	UFUNCTION(BlueprintCallable)
	void ToggleMovementPaused();
};
