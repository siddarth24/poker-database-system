import { BrowserRouter, Routes, Route } from "react-router-dom";
import HomePage from "../home/homePage";
import GamePage from "../apiPages/gamesPage";
import ReplayPage from "../apiPages/replayPage";
import AdminPage from "../apiPages/adminPage";
// import axios from "axios";

export default function AppRouter(){
return(
<BrowserRouter>
<Routes>
    <Route path="/" element={<HomePage />} />
    <Route path="/games" element={<GamePage />} />
    <Route path="/replay" element={<ReplayPage />} />
    <Route path="/admin" element={<AdminPage />} />
</Routes>
</BrowserRouter>
)
}