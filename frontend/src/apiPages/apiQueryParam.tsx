import { ChangeEvent, useState } from "react";

export enum InputType {
    String = "text",
    Number = "number",
    Bool = "checkbox",
    Date = "date"
}

export interface IApiCallQueryParam {
    name: string;
    type: InputType | IApiCallQueryParam[];
    isArray: boolean;
    placeholder: string | null;
}

export interface IApiQueryParamProps {
    queryParam: IApiCallQueryParam;
    updateFormData: (data: any) => void;
}

const ApiQueryParam: React.FC<{props: IApiQueryParamProps}> = ({props}) => {
    const [paramValues, setParamValues] = useState<any[]>([])
    const paramName = props.queryParam.name
    const paramType = props.queryParam.type
    const paramPlaceholder = props.queryParam.placeholder

    const renderSingleParam = () => {
        const handleChange = (event: ChangeEvent<HTMLInputElement>) => {
            let value
            if (event.target.type == "checkbox") {
                value = event.target.checked
            } else {
                value = event.target.value
            }
            props.updateFormData({
                [paramName]: value
            })
        };
    
        return (
            <div className="queryParam">
                    <label htmlFor={paramName}>{paramName}:</label>
                    <input
                        id={paramName}
                        name={paramName}
                        type={paramType as InputType}
                        placeholder={paramPlaceholder ? paramPlaceholder : ""}
                        onChange={handleChange}
                    />
                </div>
        )
    }

    const renderArrayParam = () => {
        if (paramValues.length == 0) {
            setParamValues([false])
        }
        
        const handleChange = (index: number, value: any) => {
            const newValues = [...paramValues];
            newValues[index] = value;
            setParamValues(newValues);
            props.updateFormData({[paramName]: newValues})
        };

        const createInputElement = (index: number) => {
            return (<input
                key={paramName+index}
                id={paramName+index}
                name={paramName+index}
                type={paramType as InputType}
                placeholder={paramPlaceholder ? paramPlaceholder : ""}
                onChange={(event) => {
                    let value
                    if (event.target.type == "checkbox") {
                        value = event.target.checked
                    } else {
                        value = event.target.value
                    }
                    handleChange(index, value)
                }}
            />)
        }

        const addInput = (event: any) => {
            event.preventDefault()
            const newValues = [...paramValues];
            newValues.push(false)
            setParamValues(newValues)
        }
        const removeInput = (event: any) => {
            event.preventDefault()
            const newValues = [...paramValues];
            if (newValues.length == 1) {
                return
            }
            newValues.pop()
            setParamValues(newValues)
        }
    
        return (
            <div className="queryParam">
                <div className="left array-label">
                    <label>{paramName}:</label>
                    <button onClick={removeInput}>-</button>
                    <button onClick={addInput}>+</button>
                </div>
                <div className="right">
                    {paramValues.map( (value, index) => (
                        createInputElement(index)
                    ))}
                </div>
            </div>
        )
    }

    const renderJsonParam = () => {
        if (paramValues.length == 0) {
            setParamValues([false])
        }
        
        const updateParamValues = (index: number, value: any) => {
            const newParams = [...paramValues]
            const newValue = {...newParams[index], ...value}
            newParams[index] = newValue
            setParamValues(newParams);
            props.updateFormData({[paramName]: newParams})
        }

        const createJsonElement = (index: number) => {
            return(<div key={props.queryParam.name + index}>
                {(props.queryParam.type as IApiCallQueryParam[]).map((queryParam: IApiCallQueryParam) => (
                    <ApiQueryParam key={props.queryParam.name + "-" + queryParam.name + index} props={{
                        queryParam: queryParam, 
                        updateFormData: (value) => updateParamValues(index, value)
                    }} />
                ))}
            </div>)
        }

        const addInput = (event: any) => {
            event.preventDefault()
            const newValues = [...paramValues];
            newValues.push(false)
            setParamValues(newValues)
        }
        const removeInput = (event: any) => {
            event.preventDefault()
            const newValues = [...paramValues];
            if (newValues.length == 1) {
                return
            }
            newValues.pop()
            setParamValues(newValues)
        }

        return (
            <div className="queryParam">
                <div className="left array-label">
                    <label>{paramName}:</label>
                    <button onClick={removeInput}>-</button>
                    <button onClick={addInput}>+</button>
                </div>
                <div className="right">
                    {paramValues.map( (value, index) => (
                        createJsonElement(index)
                    ))}
                </div>
            </div>
        )
    }

    return (Object.values(InputType).includes(props.queryParam.type as InputType)) ? 
        (props.queryParam.isArray ? renderArrayParam() : renderSingleParam()) :
        renderJsonParam()
}

export default ApiQueryParam;