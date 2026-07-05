<?php

namespace App\Enums;

enum StockMovementType: string
{
    case ProductionIn = 'production_in';
    case Sale = 'sale';
    case Adjustment = 'adjustment';
    case VoidReturn = 'void_return';
}