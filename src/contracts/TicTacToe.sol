//SPDX-License-Identifier: CC-0
pragma solidity ^0.8.13;

contract TicTacToe {
    struct Game {
        uint32 board;
        address crosses;
        address circles;
    }

    event GameCreated(uint64 id, address indexed crosses, address indexed circles);
    event GameState(uint64 indexed id, uint64 game);

    mapping(uint64 => Game) public games;

    function create_game(uint64 id, address circles) public {
        require(circles != address(0), "You can not create a new game using the empty address as the opponent address");
        require(games[id].circles == address(0), "You can not create a game with this game id because it is already taken");
        require(games[id].crosses == address(0), "You can not create a game with this game id because it is already taken");
        require(games[id].board == 0, "You can not create a game with this game id because it is already taken");

        games[id].crosses = msg.sender;
        games[id].circles = circles;
        emit GameCreated(id, msg.sender, circles);
    }

    function add_cross(uint64 id, uint8 position) public {
        require(position >= 0, "You can not add a cross at a position < 0, valid positions are between 0 and 8");
        require(position < 9, "You can not add a cross at a position > 8, valid positions are between 0 and 8");
        require(games[id].crosses == msg.sender, "You can not add a cross because your address is not the designated crosses address for this game");
        
        uint32 board = games[id].board;
        require(value_at(board, position) == 0, "You can not add a cross at this position because it is already taken");
        require(turn(board) == 1, "You can not add a cross because it is not your turn, or the game is already over");
        
        board = set_value_at(board, position, 1);
        games[id].board = board;
        emit GameState(id, board);
    }

    function add_circle(uint64 id, uint8 position) public {
        require(position >= 0, "You can not add a circle at a position < 0, valid positions are between 0 and 8");
        require(position < 9, "You can not add a circle at a position > 8, valid positions are between 0 and 8");
        require(games[id].circles == msg.sender, "You can not add a circle because your address is not the designated circles address for this game");
        
        uint32 board = games[id].board;
        require(value_at(board, position) == 0, "You can not add a circle at this position because it is already taken");
        require(turn(board) == 2, "You can not add a circle because it is not your turn, or the game is already over");

        board = set_value_at(board, position, 2);
        games[id].board = board;
        emit GameState(id, board);
    }

    /** returns 1 if turn is crosses, 2 if turn is circles, 0 if game is over */
    function turn(uint32 board) private pure returns(uint8) {
        uint8 crosses = 0;
        uint8 circles = 0;

        for (uint8 i = 0; i < 9; i++) {
            uint8 value = value_at(board, i);
            if (value == 1) crosses++;
            else if (value == 2) circles++;
        }

        uint8 current_turn = (crosses == circles) ? 1 : 2;
        uint8 last_turn = (crosses == circles) ? 2 : 1;

        uint8[3][8] memory lines = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6]
        ];

        for (uint8 i = 0; i < lines.length; i++) {
            if (is_line_won_by(board, lines[i], last_turn)) {
                return 0;
            }
        }

        return current_turn;
    }

    function is_line_won_by(uint32 board, uint8[3] memory line, uint8 winner) private pure returns(bool) {
        for (uint8 i = 0; i < line.length; i++) {
            if (value_at(board, line[i]) != winner) {
                return false;
            }
        }
        return true;
    }

    function value_at(uint32 board, uint8 index) private pure returns(uint8) {
        return uint8((board >> (index * 2)) & 3);
    }

    function set_value_at(uint32 board, uint8 index, uint8 value) private pure returns(uint32) {
        uint32 v32 = uint32(value);
        return board ^ (v32 << (index * 2));
    }
}
