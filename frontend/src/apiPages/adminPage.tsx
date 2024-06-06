import React from 'react';
import Header from '../home/header';
import ApiCall, {IApiCallProps, RequestMethod} from './apiCall';
import { InputType } from "./apiQueryParam";

const AdminPage: React.FC = () => {
    const add_player: IApiCallProps = {
        name: "Add Player",
        path: "new_player",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "name",
                type: InputType.String,
				isArray: false,
				placeholder: "",
            },
            {
                name: "home_country",
                type: InputType.String,
				isArray: false,
				placeholder: "",
            },
            {
                name: "region",
                type: InputType.String,
				isArray: false,
				placeholder: "",
            },
            {
                name: "net_winnings",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const delete_player: IApiCallProps = {
        name: "Delete Player",
        path: "delete_player",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "player_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            }
        ]
    }
    const edit_player: IApiCallProps = {
        name: "Edit Player",
        path: "edit_player",
        requestMethod: RequestMethod.PUT,
        queryParams: [
            {
                name: "player_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "name",
                type: InputType.String,
				isArray: false,
				placeholder: "",
            },
            {
                name: "home_country",
                type: InputType.String,
				isArray: false,
				placeholder: "",
            },
            {
                name: "region",
                type: InputType.String,
				isArray: false,
				placeholder: "",
            },
            {
                name: "net_winnings",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const player_summary: IApiCallProps = {
        name: "Player Summary",
        path: "players_summary",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "player_id",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "start_date",
                type: InputType.Date,
				isArray: false,
				placeholder: "",
            },
            {
                name: "end_date",
                type: InputType.Date,
				isArray: false,
				placeholder: "",
            },
        ]
    }
    const get_players_in_games: IApiCallProps = {
        name: "Get Players In Games",
        path: "get_players_in_games",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "game_ids",
                type: InputType.Number,
				isArray: true,
				placeholder: "",
            },
        ]
    }
    const season_summary: IApiCallProps = {
        name: "Season Summary",
        path: "season_summary",
        requestMethod: RequestMethod.POST,
        queryParams: [
            {
                name: "seasons",
                type: InputType.Number,
				isArray: true,
				placeholder: "",
            },
            {
                name: "min_players",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "min_games",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "min_avg_pot_size",
                type: InputType.Number,
				isArray: false,
				placeholder: "",
            },
            {
                name: "min_max_pot_size",
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
            <ApiCall props={add_player} />
            <ApiCall props={delete_player} />
            <ApiCall props={edit_player} />
            <ApiCall props={player_summary} />
            <ApiCall props={get_players_in_games} />
            <ApiCall props={season_summary} />
        </div>
        </div>
    )
}

export default AdminPage