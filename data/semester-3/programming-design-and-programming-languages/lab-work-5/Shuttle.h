#pragma once

#include <iostream>
#include "Plane.h"
#include "Rocket.h"


class Shuttle : public Plane, public Rocket
{
	public:
		Shuttle();
		Shuttle(int, int, int, int, int, int, int, FuelState, int);
		~Shuttle();

		int computeCost();
		void show();
};