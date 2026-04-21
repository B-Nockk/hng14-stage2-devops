const express = require("express");
const axios = require("axios");
const path = require("path");
const app = express();

// const API_URL = "http://localhost:8000";
const require_env = (key) => {
    const value = process.env[key];
    if (!value) {
        throw new Error(`Missing required environment variable: ${key}`);
    }
    return value;
};

const API_URL = require_env("API_URL");

app.use(express.json());
app.use(express.static(path.join(__dirname, "views")));

app.post("/submit", async (req, res) => {
    try {
        const response = await axios.post(`${API_URL}/jobs`);
        res.json(response.data);
    } catch (err) {
        const status = err.response?.status || 500;
        const detail = err.response?.data || { error: "something went wrong" };
        res.status(status).json(detail);
    }
});

app.get("/status/:id", async (req, res) => {
    try {
        const response = await axios.get(`${API_URL}/jobs/${req.params.id}`);
        res.json(response.data);
    } catch (err) {
        const status = err.response?.status || 500;
        const detail = err.response?.data || { error: "something went wrong" };
        res.status(status).json(detail);
    }
});

app.get("/healthz", (req, res) => {
    res.json({ status: 200, message: "Frontend is healthy" });
});

const PORT = parseInt(require_env("SERVICE_PORT"));
app.listen(PORT, () => console.log(`Frontend running on port ${PORT}`));
