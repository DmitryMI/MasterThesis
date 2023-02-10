// Fill out your copyright notice in the Description page of Project Settings.


#include "RadioSender.h"
#include "Kismet/GameplayStatics.h"
#include "DrawDebugHelpers.h"

// Sets default values
ARadioSender::ARadioSender()
{
 	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

void ARadioSender::DrawLineOfSight(ARadioReceiver* receiver)
{
	FVector senderLocation = GetActorLocation();
	FVector receiverLocation = receiver->GetActorLocation();

	DrawDebugLine(GetWorld(), senderLocation, receiverLocation, FColor::Blue);

	for (AObstacle3d* obstacle : radioObstacles)
	{
		if (obstacle == nullptr)
		{
			continue;
		}
		TArray<FVector> intersections;
		obstacle->GetIntersections(senderLocation, receiverLocation, intersections);

		for (FVector intersection : intersections)
		{
			DrawDebugSphere(GetWorld(), intersection, 10.0f, 8, FColor::Red);
		}
	}
}

// Called when the game starts or when spawned
void ARadioSender::BeginPlay()
{
	Super::BeginPlay();
	
	TArray<AActor*> receivers;
	UGameplayStatics::GetAllActorsOfClass(GetWorld(), ARadioReceiver::StaticClass(), receivers);
	TArray<AActor*> obstacles;
	UGameplayStatics::GetAllActorsOfClass(GetWorld(), AObstacle3d::StaticClass(), obstacles);

	for (AActor* actor : receivers)
	{
		radioReceivers.Add(Cast<ARadioReceiver>(actor));
	}

	for (AActor* actor : obstacles)
	{
		radioObstacles.Add(Cast<AObstacle3d>(actor));
	}
}

// Called every frame
void ARadioSender::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	for (ARadioReceiver* receiver : radioReceivers)
	{
		if (receiver == nullptr)
		{
			continue;
		}
		DrawLineOfSight(receiver);
	}

}

