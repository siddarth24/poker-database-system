import React from 'react';
import Header from '../home/header';
import ApiCall, {IApiCallProps, RequestMethod} from './apiCall';
import { InputType } from "./apiQueryParam";

const GamePage: React.FC = () => {
    const new_game: IApiCallProps = {
        name: "New Game",
        path: "new_game",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "date",
                type: InputType.Date,
				isArray: false,
				placeholder: "YYYY:mm:dd",
            },
            {
                name: "season_number",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "in_tournament",
                type: InputType.Bool,
				isArray: false,
				placeholder: "",
            },
            {
                name: "tournament_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const delete_game: IApiCallProps = {
        name: "Delete Game",
        path: "delete_game",
        requestMethod: RequestMethod.DELETE,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            }
        ]
    }
    const buy_in: IApiCallProps = {
        name: "Buy in",
        path: "buy_in",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "buy_ins",
                type: [
                    {
                        name: "player_id",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "amount",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                ],
				isArray: true,
				placeholder: "",
            },
        ]
    }
    const cash_out: IApiCallProps = {
        name: "Cash out",
        path: "cash_out",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "cash_outs",
                type: [
                    {
                        name: "player_id",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "amount",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                ],
				isArray: true,
				placeholder: "",
            },
        ]
    }
    const add_match: IApiCallProps = {
        name: "Add Match",
        path: "add_match",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "hole_cards",
                type: [
                    {
                        name: "player_id",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "card1_id",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "card2_id",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    }
                ],
				isArray: true,
				placeholder: "",
            },
        ]
    }
    const delete_match: IApiCallProps = {
        name: "Delete Match",
        path: "delete_match",
        requestMethod: RequestMethod.DELETE,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            }
        ]
    }

    const add_round: IApiCallProps = {
        name: "Add Round",
        path: "add_round",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "pot_size",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "card1_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "card2_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "card3_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "actions",
                type: [
                    {
                        name: "player_id",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "amount",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "action",
                        type: InputType.String,
                        isArray: false,
                        placeholder: "",
                    },
                    {
                        name: "ending_balance",
                        type: InputType.Number,
                        isArray: false,
                        placeholder: "",
                    },
                ],
				isArray: true,
				placeholder: "",
            },
        ]
    }

    const delete_round: IApiCallProps = {
        name: "Delete Round",
        path: "delete_round",
        requestMethod: RequestMethod.DELETE,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }

    return (
        <div>
            <Header />
        <div className='api-page'>
            <ApiCall props={new_game} />
            <ApiCall props={delete_game} />
            <ApiCall props={buy_in} />
            <ApiCall props={cash_out} />
            <ApiCall props={add_match} />
            <ApiCall props={delete_match} />
            <ApiCall props={add_round} />
            <ApiCall props={delete_round} />
        </div>
        </div>
    )
}

export default GamePage