const express = require('express')
const Visit = require('../models/visit')
const auth = require('../middleware/auth')
const router = new express.Router()

router.post('/visits', auth, async (req, res) => {
    const visit = new Visit({
        ...req.body,
        owner: req.user._id
    })

    try { 
        await visit.save()
        res.status(201).send(visit)
    } catch (e) {
        res.status(400).send(e)
    }
})
 
// GET /visits?visited=true
// GET /visits?limit=10&skip=20
// GET /visits?sortBy=createdAt:desc
router.get('/visits', auth, async (req, res) => {
    const match = {}
    const sort = {}

    if (req.query.visited) {
        match.visited = req.query.visited === 'true'
    }

    if (req.query.sortBy) {
        const parts = req.query.sortBy.split(':')
        sort[parts[0]] = parts[1] === 'desc' ? -1 : 1
    }

    try {
        await req.user.populate({
            path: 'visits',
            match,
            options: {
                limit: parseInt(req.query.limit),
                skip: parseInt(req.query.skip),
                sort
            }
        }).execPopulate()
        res.send(req.user.visits)
    } catch (e) {
        res.status(500).send()
    }
})

router.get('/visits/:id', auth, async (req, res) => {
    const _id = req.params.id

    try {
        const visit = await Visit.findOne({ _id, owner: req.user._id })

        if (!visit) {
            return res.status(404).send()
        }

        res.send(visit)
    } catch (e) {
        res.status(500).send()
    }
})

router.patch('/visits/:id', auth, async (req, res) => {
    const updates = Object.keys(req.body)
    const allowedUpdates = ['visited']
    const isValidOperation = updates.every((update) => allowedUpdates.includes(update))

    if (!isValidOperation) {
        return res.status(400).send({ error: 'Invalid updates!' })
    }

    try {
        const visit = await Visit.findOne({ _id: req.params.id, owner: req.user._id})

        if (!visit) {
            return res.status(404).send()
        }

        updates.forEach((update) => visit[update] = req.body[update])
        await visit.save()
        res.send(visit)
    } catch (e) {
        res.status(400).send(e)
    }
})

router.delete('/visits/:id', auth, async (req, res) => {
    try {
        const visit = await Visit.findOneAndDelete({ _id: req.params.id, owner: req.user._id })

        if (!visit) {
            res.status(404).send()
        }

        res.send(visit)
    } catch (e) {
        res.status(500).send()
    }
})

module.exports = router