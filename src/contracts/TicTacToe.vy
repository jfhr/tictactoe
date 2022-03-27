struct Game:
    board: String[9]
    crosses: address
    circles: address


event GameCreated:
    id: uint256
    crosses: indexed(address)
    circles: indexed(address)


event MoveCreated:
    id: indexed(uint256)
    board: String[9]


games: HashMap[uint256, Game]


@external
def create_game(id: uint256, circles: address):
    assert circles != empty(address)
    
    assert self.games[id].crosses == empty(address)
    assert self.games[id].circles == empty(address)

    self.games[id].crosses = msg.sender
    self.games[id].circles = circles

    log GameCreated(id, msg.sender, circles)


@external
def add_cross(id: uint256, position: uint8):
    assert position < 9

    assert self.games[id].crosses == msg.sender

    assert self.games[id].board[position] == "\0"
    self.games[id].board[position] = "x"

    log MoveCreated(id, self.games[id].board)


@external
def add_circle(id: uint256, position: uint8):
    assert position < 9

    assert self.games[id].circles == msg.sender

    assert self.games[id].board[position] == "\0"
    self.games[id].board[position] = "o"

    log MoveCreated(id, self.games[id].board)
