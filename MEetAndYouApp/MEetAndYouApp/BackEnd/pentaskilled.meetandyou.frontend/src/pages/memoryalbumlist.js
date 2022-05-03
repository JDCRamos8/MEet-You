import React, { useState, useEffect } from 'react';
import Image from './memoryalbum'
import axios from "axios";
import MemoryAlbum from './memoryalbum';

function MemoryAlbumList() {
    const [memoryAlbumList, setmemoryAlbumList] = useState([])
    const [recordForEdit, setRecordForEdit] = useState(null)

    const [imageID, setImageID] = useState();
    const [imageName, setImageName] = useState();
    const [imageExtension, setExtension] = useState("");
    const [imagePath, setPath] = useState("")
    const [response, setResponse] = useState();
    useEffect(() => {
        refreshmemoryAlbumList();
    }, [])


    const createImages = async (request) => {
        const requestOptions = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': true
            }
        }

        console.log("Image ID:", imageID)
        console.log("Image Name", imageName)
        console.log("Image Extension", imageExtension)
        console.log("Image Path:", imagePath)

        try {
            const res = await fetch('https://localhost:9000/MemoryAlbum', requestOptions);
            const AddedImage = await res.json();
            // setResponse(AddedImage.data)
            // console.log(AddedImage)
            return AddedImage
        }
        catch (error) {
            console.log('error');
        }
    }



    const getImages = async () => {
        const requestOptions = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': true
            }
        }
        try {
            const res = await fetch('https://localhost:9000/MemoryAlbum');
            const suggestionResponse = await res.json();
            return suggestionResponse
        }
        catch (error) {
            console.log('error');
        }
    }


    // function displayPostResponse() {
    //     if (postRes.isSuccessful === false) {
    //         setpostMsg(<p>Save image failed, please try again</p>)
    //     }
    //     else {
    //         setpostMsg(<p>Save image was successful</p>)
    //     }
    // }
    function refreshmemoryAlbumList() {
        getImages()
            .then(res => {
                setmemoryAlbumList(res.data)
            })
            .catch(err => console.log(err))
    }

    const addOrEdit = (formData, onSuccess) => {
        if (formData.get('imageID') == "0")
            createImages(formData)
                .then(res => {
                    onSuccess();
                    refreshmemoryAlbumList();
                })
                .catch(err => console.log(err))
        // else
        //     imagesAPI().update(formData.get('imageID'), formData)
        //         .then(res => {
        //             onSuccess();
        //             refreshmemoryAlbumList();
        //         })
        //         .catch(err => console.log(err))

    }

    const showRecordDetails = data => {
        setRecordForEdit(data)
    }

    // const onDelete = (e, id) => {
    //     e.stopPropagation();
    //     if (window.confirm('Are you sure to delete this record?'))
    //         imagesAPI().delete(id)
    //             .then(res => refreshmemoryAlbumList())
    //             .catch(err => console.log(err))
    // }

    const imageCard = data => (
        <div className="card" onClick={() => { showRecordDetails(data) }}>
            <img src={data.imageSrc} className="card-img-top rounded-circle" />
            <div className="card-body">
                <h5>{data.ImageName}</h5>
                <span>{data.imageSrc}</span> <br />
                {/* <button className="btn btn-light delete-button" onClick={e => onDelete(e, parseInt(data.imageID))}> */}
                <i className="far fa-trash-alt"></i>
                {/* </button> */}
            </div>
        </div>
    )


    return (
        <div className="row">
            <div className="col-md-12">
                <div className="jumbotron jumbotron-fluid py-4">
                    <div className="container text-center">
                        <h1 className="display-4">Image Register</h1>
                    </div>
                </div>
            </div>
            <div className="col-md-4">
                <MemoryAlbum
                    addOrEdit={addOrEdit}
                    recordForEdit={recordForEdit}
                />
            </div>
            <div className="col-md-8">
                <table>
                    <tbody>
                        {
                            //tr > 3 td
                            [...Array(Math.ceil(memoryAlbumList.length / 3))].map((e, i) =>
                                <tr key={i}>
                                    <td>{imageCard(memoryAlbumList[3 * i])}</td>
                                    <td>{memoryAlbumList[3 * i + 1] ? imageCard(memoryAlbumList[3 * i + 1]) : null}</td>
                                    <td>{memoryAlbumList[3 * i + 2] ? imageCard(memoryAlbumList[3 * i + 2]) : null}</td>
                                </tr>
                            )
                        }
                    </tbody>
                </table>
            </div>
        </div>
    )
}

export default MemoryAlbumList;