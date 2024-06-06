import React, { ChangeEvent, useContext, useState } from 'react';
import axios from "axios";
import GlobalContext from '../contexts/globalContext';
import ApiQueryParam, { IApiCallQueryParam } from './apiQueryParam';

export interface IApiCallProps {
    name: string;
    path: string;
    requestMethod: RequestMethod;
    queryParams: IApiCallQueryParam[];
}

export enum RequestMethod {
    GET,
    POST,
    DELETE,
    PUT
}

const ApiCall: React.FC<{props: IApiCallProps}> = ({props}) => {
    const [ formData, setFormData ] = useState({})
    const [ response, setResponse ] = useState({})
    const globalContext = useContext(GlobalContext);
    const apiEndpoint = globalContext.api_endpoint;

    // const config = {
    //     data: formData, // For sending a request body with axios.delete
    //     params: formData // For appending query params with the URL
    // };

    // let requestMethod;
    // switch (props.requestMethod) {
    //     case RequestMethod.DELETE:
    //         requestMethod = () => axios.delete(`${apiEndpoint}/${props.path}`, config);
    //         break;
    //     case RequestMethod.PUT:
    //         requestMethod = () => axios.put(`${apiEndpoint}/${props.path}`, formData);
    //         break;
    //     case RequestMethod.POST:
    //         requestMethod = () => axios.post(`${apiEndpoint}/${props.path}`, formData);
    //         break;
    //     case RequestMethod.GET:
    //         requestMethod = () => axios.get(`${apiEndpoint}/${props.path}`, { params: formData });
    //         break;
    //     default:
    //         requestMethod = () => axios.post(`${apiEndpoint}/${props.path}`, formData);
    // }

    const handleSubmit = (event: any) => {
        event.preventDefault()
        let requestMethod, config
        switch (props.requestMethod) {
            case RequestMethod.DELETE:
                config = {
                    data: formData
                }
                requestMethod = axios.delete
                break;
            case RequestMethod.PUT:
                config = formData
                requestMethod = axios.put
                break;
            case RequestMethod.POST:
                config = formData
                requestMethod = axios.post
                break;
            case RequestMethod.GET:
                config = {
                    params: formData
                }
                requestMethod = axios.get
                break;
            default:
                config = formData
                requestMethod = axios.post
        }
        console.log(config)
        requestMethod(`${apiEndpoint}/${props.path}`, config).then((response)=>{
            let data = response.data
            setResponse(data)
            console.log(response)
        }).catch( (e) => {
            console.log(e)
            const errorData = {
                "error name": e.name,
                "error code": e.code,
                "error message": e.message
            }
            setResponse(errorData)
        })
    };

    const updateFormData = (newData: any) => {
        setFormData({ ...formData, ...newData });
    }

  return (
    <div className='api-call'>
        <h1>{props.name}</h1>
        <form>
        {props.queryParams.map((queryParam, index) => (
            <ApiQueryParam key={queryParam.name} props={{queryParam: queryParam, updateFormData: updateFormData}} />
        ))}
        <button type="submit" className='submit-button' onClick={handleSubmit}>Submit</button>
        </form>
        <h1>Response:</h1>
        <pre>{JSON.stringify(response, null, 2)}</pre>
    </div>
  )
}
export default ApiCall;