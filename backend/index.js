import express from 'express';
import bodyParser from 'body-parser';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import authentification from './middleware/auth.js';

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
const port = 3000;
const prisma = new PrismaClient();
const apiRouter = express.Router();
app.use('/api', apiRouter);

apiRouter.get('/', authentification,  (req,res) =>{
    res.json({message: 'Hello World!'});
})

apiRouter.post('/register', async (req,res) =>{
    const {username, password, email} = req.body;
    
    const user = await prisma.user.findFirst({
        where: {
            OR:[
                {
                    username: username,
                    deletedAt: null,
                },
                {
                    deletedAt: null,
                    email: email
                },
            ]
        }
    })

    if(user){
        res.status(400).json({message: 'User/Email already exists'});
    }else{
        const cryptPassword = await bcrypt.hash(password, 10);
        await prisma.user.create({
            data: {
                username: username,
                password: cryptPassword,
                email: email,

            }
        }).then(() =>{
            res.status(200).json({message: 'User created successfully'});
        })
    }
})

apiRouter.post('/login', async (req,res) =>{
    const {username, password} = req.body;
    console.log(username, password)
    try {
        const user = await prisma.user.findFirst({
            where: {
                username: username,
                deletedAt: null,
            }
        })
        if(!user){
            res.status(404).json({message: 'User not found'});
        }else{
            await bcrypt.compare(password,user.password).then(isValid => {
                if(isValid){
                    const token = jwt.sign({
                        data: {
                            username: user.username,
                            email: user.email,
                            userId: user.id
                        }}, 'fiqriGanteng', {expiresIn: '1h'});
                    res.status(200).json({token: token});
                }
            })
        }
        
    } catch (error) {
        res.status(500).json({message: 'Internal Server Error'});
    }


})

apiRouter.get('/transaction', authentification, async(req,res) =>{
    const transactions = await prisma.transaction.findMany({
        where:{
            deletedAt: null
        }
    });
    res.json(transactions);
})

apiRouter.post('/transaction', authentification, async(req,res) =>{
    const {type, category, amount, description} = req.body;
    const user = req.user;

    try {        
        var CategoryId = await prisma.category.findFirst({
            where: {
                name: category,
                deletedAt: null,
            }
        })
    
        if(!CategoryId){
            CategoryId = await prisma.category.create({
                data: {
                    name: category,
                    description: ""
                }
            })
    
        }
    
        const transaction = await prisma.transaction.create({
            data: {
              type: type,
              amount: parseFloat(amount),
              description: description,
              user: {
                connect: { id: user.userId } // Hubungkan ke User yang sudah ada
              },
              category: {
                connect: { id: CategoryId.id } // Hubungkan ke Category yang sudah ada
              }
            }
          });

        res.json(transaction);
    } catch (error) {
        res.json({error: error})
        console.log(error)
    }
    

})

apiRouter.get('/transaction/:id', authentification, async(req,res) =>{
    const id = parseInt(req.params.id);
    const transaction = await prisma.transaction.findFirst({
        where:{
            id: id,
            deletedAt: null,
        }
    })
    res.json(transaction);
})

apiRouter.put('/transaction/:id', authentification, async(req,res) =>{
    const id = parseInt(req.params.id);
    const {type, category, amount, description} = req.body;
    const user = req.user;
    const updateData = {}

    try {
        if(category){
            var CategoryId = await prisma.category.findFirst({
                where: {
                    name: category,
                    deletedAt: null
                }
            })
    
            if(!CategoryId){
                CategoryId = await prisma.category.create({
                    data:{
                        name: category,
                        description: "",
                    }
                })   
            }
        }

        if(type) updateData.type = type;
        if(amount) updateData.amount = parseFloat(amount);
        if(CategoryId) updateData.CategoryId = CategoryId;
        if(description) updateData.description = description;

        const transaction = await prisma.transaction.update({
            where:{
                id:id,
                deletedAt: null,
            },
            data: updateData,
        })
        res.json(transaction);

        
    } catch (error) {
        res.json({error: error})
        console.log(error)
    }
})


apiRouter.delete('/transaction/:id', authentification, async(req,res) =>{
    const id = parseInt(req.params.id);

    try {
        const softDeleteData = await prisma.transaction.update({
            where:{
                id: id
            },
            data:{
                deletedAt: new Date(),
            }
        }) 
        res.json(softDeleteData)
    } catch (error) {
        res.json(error)
    }

})


apiRouter.get('/category', authentification, async(req,res) =>{
    
    try {
        
        const categoryData = await prisma.category.findMany({
            where:{
                deletedAt: null,
            }
        })
        res.json(categoryData)
    } catch (error) {
        res.json(error)
    }
    
})

apiRouter.post('/category', authentification, async(req,res) =>{
    const {name, description} = req.body;
    try {
        const category = await prisma.category.findFirst({
            where:{
                name: name,
                deletedAt: null,
            }
        })
        if(category){
            res.json({message: 'Category already exists'})
            return;
        }
        
        const categoryInput = await prisma.category.create({
            data: {
                name: name,
                description: description,
            }
        })
        res.json(categoryInput)
    } catch (error) {
        res.json(error)
        console.log(error)
    }
})

apiRouter.delete('/category/:id', authentification, async(req,res) =>{
    const id = parseInt(req.params.id)
    try {
        const categoryDelete = await prisma.category.update({
            where:{
                id:id
            },
            data:{
                deletedAt: new Date()
            }
        })
        res.json(categoryDelete)
    } catch (error) {
        console.log(error)
    }
})

app.listen(port, () =>{
    console.log(`Server is running on port ${port}`);
})