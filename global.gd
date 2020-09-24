extends Node

const TERRAIN_TYPE_ROCKY = 1
const TERRAIN_TYPE_HILLY = 3
const TERRAIN_TYPE_IN_BETWEEN = 5
const TERRAIN_TYPE_FLAT = 20

const TERRAIN_MULTIPLIER_NORMAL = 1
const TERRAIN_MULTIPLIER_BIGBOI = 2
const TERRAIN_MULTIPLIER_AMPLIFIED = 5

const TERRAIN_RESOLUTION_PS1_HAGRID = 4
const TERRAIN_RESOLUTION_COARSE = 2
const TERRAIN_RESOLUTION_FINE = 1

var subchunkCollisionSize = 4
var chunkSize = 16
var terrainResolution = TERRAIN_RESOLUTION_FINE
var terrainMultiplier = TERRAIN_MULTIPLIER_NORMAL
var terrainType = TERRAIN_TYPE_IN_BETWEEN

var renderDistance = 11

const ITEM_AIR = 0
const ITEM_FLOOR = 1
const ITEM_PLATINUM = 2
const ITEM_GOLD = 3

const ITEM_DEBUG = 99

var playerInventory = []
var currentInventorySlotSelected = 0
