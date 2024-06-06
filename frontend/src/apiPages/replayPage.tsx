import React from 'react';
import Header from '../home/header';
import ApiCall, {IApiCallProps, RequestMethod} from './apiCall';
import { InputType } from "./apiQueryParam";

const ReplayPage: React.FC = () => {
    const list_games: IApiCallProps = {
        name: "List Games",
        path: "get_games",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "offset",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "limit",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const list_matches: IApiCallProps = {
        name: "List Matches",
        path: "get_matches",
        requestMethod: RequestMethod.GET,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "offset",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "limit",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const list_rounds: IApiCallProps = {
        name: "List Rounds",
        path: "get_rounds",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "game_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "match_number",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "match_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "offset",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "limit",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const list_player_games: IApiCallProps = {
        name: "List Player Games",
        path: "get_player_games",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "player_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "offset",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "limit",
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
            <ApiCall props={list_games} />
            <ApiCall props={list_matches} />
            <ApiCall props={list_rounds} />
            <ApiCall props={list_player_games} />
        </div>
        </div>
    )
}

export default ReplayPage