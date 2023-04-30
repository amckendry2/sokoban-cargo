class_name BlockLogic extends Node2D

enum BlockColor {RED, GREEN, BLUE, YELLOW}

static func getRandomColor():
	var keys = BlockColor.keys()
	return BlockColor[keys[randi() % len(keys)]]

enum MoveDirection {EAST, NORTH, WEST, SOUTH}

static func directionToVec(direction):
	match direction:
		MoveDirection.EAST:
			return Vector2(1, 0)
		MoveDirection.NORTH:
			return Vector2(0, -1)
		MoveDirection.WEST:
			return Vector2(-1, 0)
		MoveDirection.SOUTH:
			return Vector2(0, 1)

# A Block is a continuous group of cells, and a color
# Block ::
#   Dict
#     { "cells" :: Set (Vector2 Int) -- Invariant: Positions must form one contiguous group
#     , "color" :: BlockColor
#     }

# Unsafe constructor.
# Make a block from a contiguous set of cells. No check is performed for the
# contiguousness of the cells.
static func makeSingleCellBlock(cell: Vector2, color) -> Dictionary:
	var cells = {}
	cells[cell] = null
	return { "cells": cells, "color": color }

static func makeBlock(cells: Dictionary, color) -> Dictionary:
	return { "cells": cells, "color": color }

# Safe constructor.
# Create a set of blocks from a set of cells and a color.
static func makeBlocks(cells: Dictionary, color) -> Dictionary:
	var singletonBlocks = {} # accumulator
	for cell in cells:
		var newSingletonCell = { cell: null }
		var newSingletonBlock = makeBlock(newSingletonCell, color)
		singletonBlocks[newSingletonBlock] = null

	return fuseBlocks(singletonBlocks)

# Given a set of blocks, fuse adjacent blocks of the same color.
static func fuseBlocks(blocks: Dictionary) -> Dictionary:
	var newBlocks = {} # accumulator
	for block in blocks:
		var mergedSomething = false
		for newBlock in newBlocks:
			var sameColor = block.color == newBlock.color
			var areAdjacent = \
				areContiguousCellSetsAdjacent(block.cells, newBlock.cells)
			var shouldMerge = sameColor and areAdjacent
			if shouldMerge:
				var newCells = unionDicts(block.cells, newBlock.cells)
				var mergedBlock = makeBlock(newCells, block.color)

				# Replace
				newBlocks.erase(newBlock)
				newBlocks[mergedBlock] = null

				mergedSomething = true
				break

		if not mergedSomething:
			# If we didn't merge `block` with any existing block, just add it
			# as a separate block
			newBlocks[block] = null
	return newBlocks

# Apply `offsetCells` to the cells of a block.
static func offsetBlock(direction, block) -> Dictionary:
	var newCells = offsetCells(direction, block.cells)
	return makeBlock(newCells, block.color)

# Uniformly shift the position of all cells.
static func offsetCells(direction, cells: Dictionary) -> Dictionary:
	var offset = directionToVec(direction)
	var newCells = {} # accumulator
	for position in cells:
		var newPosition = position + offset
		newCells[newPosition] = null
	return newCells

# Test whether two sets of cells are adjacent (or overlapping)
static func areContiguousCellSetsAdjacent(cells1: Dictionary, cells2: Dictionary) -> bool:
	var adjacentCells1 = withAdjacentCells(cells1)
	return anyInDict(adjacentCells1, cells2)

# Given a set of cells, return a superset of cells additionally containing all
# of the adjacent cells.
static func withAdjacentCells(cells: Dictionary) -> Dictionary:
	var newCells = {} # accumulator
	for position in cells:
		newCells[position] = null
		newCells[position + Vector2(1, 0)]  = null
		newCells[position + Vector2(-1, 0)] = null
		newCells[position + Vector2(0, 1)]  = null
		newCells[position + Vector2(0, -1)]  = null
	return newCells

# Test whether the given dictionary has any of the given keys
static func anyInDict(dict: Dictionary, keys) -> bool:
	for key in keys:
		if dict.has(key):
			return true
	return false

# Merge two dictionaries. If there is a key collision, use the value from the
# left dictionary.
static func unionDicts(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var newDict = {} # accumulator
	for key1 in dict1:
		newDict[key1] = dict1[key1]
	for key2 in dict2:
		if not newDict.has(key2):
			newDict[key2] = dict2[key2]
	return newDict

# Subtract from the left dictionary the key of the right dictionary
static func diffDicts(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var newDict = {} # accumulator
	for key1 in dict1:
		if not dict2.has(key1):
			newDict[key1] = dict1[key1]
	return newDict

# Take the intersection of two dictionaries, using the values from the left
# dictionary.
static func intersectionDicts(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var newDict = {} # accumulator
	for key1 in dict1:
		if dict2.has(key1):
			newDict[key1] = dict1[key1]
	return newDict

# Compute updated positions and groupings of blocks.
#
# `otherBlocks` is a set of blocks.
# Returns a dictionary with two fields: "finalBlocks", containing the new
# configuration of blocks, and "movedBlocks", containing the initial positions
# (i.e. before the move) of blocks that moved.
static func pushBlock(direction, blockToPush, otherBlocks: Dictionary, openSpaces: Dictionary) -> Dictionary:
	# First test if we should be pushing the block at all.
	if not isPushValid(direction, blockToPush, otherBlocks, openSpaces):
		# Nope, just return the original state.
		var newBlocks = otherBlocks.duplicate(true) # accumulator
		newBlocks[blockToPush] = null
		return {
			"finalBlocks": newBlocks,
			"movedBlocks": {}
			}

	# Looks good, now push the block.

	# Queue of blocks to move
	var blocksToMoveQueue = [blockToPush] # pop from front, push at back
	# Record of original positions of moved blocks
	var movedBlocksInitAcc = {} # accumulator
	# Record of new positions of moved blocks
	var movedBlocksFinalAcc = {} # accumulator
	# Blocks for which we don't yet know whether they need to be moved
	var unmovedBlocks: Dictionary = otherBlocks.duplicate(true) # blocks that haven't been moved yet

	# All other blocks move individually.
	# I think the order of movement doesn't matter.
	while not len(blocksToMoveQueue) == 0:
		var newUnmovedBlocksAcc = {} # accumulator
		var blockToMove = blocksToMoveQueue.pop_front()
		var movedBlock = offsetBlock(direction, blockToMove)

		# Record final position of moved block
		movedBlocksFinalAcc[movedBlock] = null

		for unmovedBlock in unmovedBlocks:
			var cellsToBeMoved = intersectionDicts(movedBlock.cells, unmovedBlock.cells) # offset not yet applied
			if len(cellsToBeMoved) == 0:
				# Just keep block for next iteration
				newUnmovedBlocksAcc[unmovedBlock] = null
			else:
				# Moved cells may no longer be contiguous, so we need to split them
				var newBlocksToBeMoved = makeBlocks(cellsToBeMoved, unmovedBlock.color)

				# Unmoved cells may no longer be contiguous, so we need to split them
				var newUnmovedCells = diffDicts(unmovedBlock.cells, cellsToBeMoved)
				var newUnmovedBlocks = makeBlocks(newUnmovedCells, unmovedBlock.color)

				for newBlockToBeMoved in newBlocksToBeMoved:
					blocksToMoveQueue.push_back(newBlockToBeMoved)
				for newUnmovedBlock in newUnmovedBlocks:
					newUnmovedBlocksAcc[newUnmovedBlock] = null

		# Loop
		unmovedBlocks = newUnmovedBlocksAcc
		movedBlocksInitAcc[blockToMove] = null

	# All movements have now been procesed. Collect all blocks and perform
	# fusion.
	var newBlocks = fuseBlocks(unionDicts(movedBlocksFinalAcc, unmovedBlocks))

	# Return the updated set of blocks, along with all the blocks that moved
	# (in their unmerged form) for animation purposes.
	return {
		"finalBlocks": newBlocks,
		"movedBlocks": movedBlocksInitAcc # original positions before move
		}

# Test whether a block can be pushed in a certain direction.
static func isPushValid(direction, blockToPush, otherBlocks: Dictionary, openSpaces: Dictionary) -> bool:
	match direction:
		MoveDirection.EAST:
			return isPushEastValid(blockToPush, otherBlocks, openSpaces)
		MoveDirection.NORTH:
			# rotate everything clockwise
			var newBlockToPush = makeBlock(rotateCellsCW(blockToPush.cells), blockToPush.color)
			var newOpenSpaces = rotateCellsCW(openSpaces)
			var newOtherBlocks = {} # accumulator
			for otherBlock in otherBlocks:
				newOtherBlocks[makeBlock(rotateCellsCW(otherBlock.cells), otherBlock.color)] = null
			return isPushEastValid(newBlockToPush, newOtherBlocks, newOpenSpaces)
		MoveDirection.WEST:
			# rotate everything 180 degrees
			var newBlockToPush = makeBlock(rotateCells180(blockToPush.cells), blockToPush.color)
			var newOpenSpaces = rotateCells180(openSpaces)
			var newOtherBlocks = {} # accumulator
			for otherBlock in otherBlocks:
				newOtherBlocks[makeBlock(rotateCells180(otherBlock.cells), otherBlock.color)] = null
			return isPushEastValid(newBlockToPush, newOtherBlocks, newOpenSpaces)
		MoveDirection.SOUTH:
			# rotate everything counterclockwise
			var newBlockToPush = makeBlock(rotateCellsCCW(blockToPush.cells), blockToPush.color)
			var newOpenSpaces = rotateCellsCCW(openSpaces)
			var newOtherBlocks = {} # accumulator
			for otherBlock in otherBlocks:
				newOtherBlocks[makeBlock(rotateCellsCCW(otherBlock.cells), otherBlock.color)] = null
			return isPushEastValid(newBlockToPush, newOtherBlocks, newOpenSpaces)
		_:
			assert(false, "ERROR: Invalid direction");
			return false # to satisfy the "type checker"

static func rotateCellsCCW(cells: Dictionary) -> Dictionary:
	var newCells = {} # accumulator
	for position in cells:
		var newPosition = Vector2(-position[1], position[0])
		newCells[newPosition] = null
	return newCells

static func rotateCellsCW(cells: Dictionary) -> Dictionary:
	var newCells = {} # accumulator
	for position in cells:
		var newPosition = Vector2(position[1], -position[0])
		newCells[newPosition] = null
	return newCells

static func rotateCells180(cells: Dictionary) -> Dictionary:
	var newCells = {} # accumulator
	for position in cells:
		var newPosition = -position
		newCells[newPosition] = null
	return newCells

static func isPushEastValid(blockToPush, otherBlocks: Dictionary, openSpaces: Dictionary) -> bool:
	var blockToPush_cells_y = projectCells_y(blockToPush.cells)

	# For each y-coordinate, perform a horizontal scan.
	for y in blockToPush_cells_y:
		# Find right-most coordinate of the block to be pushed
		var blockToPush_max_x = null
		for position in blockToPush.cells:
			if position[1] == y:
				blockToPush_max_x = max(blockToPush_max_x, position[0])

		# Scan east from that right-most coordinate looking for a free spot.
		var x = blockToPush_max_x + 1
		while true:
			var position = Vector2(x, y)
			if not openSpaces.has(position):
				# We haven't found a free spot yet and now we know there's no room
				return false
			if not isBlockAtPosition(position, otherBlocks):
				# We found a free spot! This row is fine, so break out of the loop.
				break
			# Loop
			x += 1
	# We scanned every row and found an empty spot. The push looks good!
	return true

# Project onto the y-axis a set of 2D coordinates to create a set of 1D
# coordinates.
static func projectCells_y(cells: Dictionary) -> Dictionary:
	var y_positions = {} # accumulator
	for position in cells:
		y_positions[position[1]] = null
	return y_positions

static func isBlockAtPosition(position, blocks: Dictionary) -> bool:
	return findBlockAtPosition(position, blocks).foundBlock != null

# Find a block from a set of blocks with a cell at the given position. If there
# is such a block, returns that block, along with the set of blocks with that
# block removed. If there is no such block, returns `null` and the original set
# of blocks.
static func findBlockAtPosition(position, blocks: Dictionary) -> Dictionary:
	for block in blocks:
		if block.cells.has(position):
			var newBlocks = blocks.duplicate(true)
			newBlocks.erase(block)
			return { "foundBlock": block, "otherBlocks": newBlocks }
	return { "foundBlock": null, "otherBlocks": blocks }

# Separate a set of blocks by their color.
static func partitionTilesByColor(blocks: Dictionary) -> Dictionary:
	var redBlocks = {}
	var greenBlocks = {}
	var blueBlocks = {}
	var yellowBlocks = {}
	for block in blocks:
		match block.color:
			BlockColor.RED:
				redBlocks[block] = null
			BlockColor.GREEN:
				greenBlocks[block] = null
			BlockColor.BLUE:
				blueBlocks[block] = null
			BlockColor.YELLOW:
				yellowBlocks[block] = null
	return {
		"redBlocks": redBlocks,
		"greenBlocks": greenBlocks,
		"blueBlocks": blueBlocks,
		"yellowBlocks": yellowBlocks
		}
