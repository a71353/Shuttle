const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise'); // Usar a versão com suporte a async/await

const app = express();
app.use(bodyParser.json());

// Configuração da ligação à base de dados
const db = mysql.createPool({
  host: 'localhost',  // Atualiza com o teu host
  user: 'root',       // Substitui pelo teu utilizador
  password: 'guguinha111',       // Insere a tua password
  database: 'shuttle_db', // Nome da base de dados
});

// Endpoint de login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  console.log('Requisição recebida:', req.body); // Loga a requisição

  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE email = ? AND password = ?',
      [email, password]
    );
    console.log('Resultado da consulta:', rows); // Loga o resultado do banco

    if (rows.length === 0) {
      console.log('Credenciais inválidas');
      return res.status(401).json({ message: 'Credenciais inválidas' });
    }

    const user = rows[0];

    if (!user.isApproved) {
      console.log('Conta não aprovada');
      return res.status(403).json({ message: 'Conta não aprovada', isApproved: false });
    }

    console.log('Login bem-sucedido');
    return res.status(200).json({ message: 'Login bem-sucedido', isApproved: true });
  } catch (error) {
    console.error('Erro no servidor:', error); // Loga qualquer erro
    return res.status(500).json({ message: 'Erro interno no servidor' });
  }
});

app.get('/trips/pending', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM trips WHERE status = "pending"'
    );
    return res.status(200).json(rows);
  } catch (error) {
    console.error('Erro ao buscar viagens pendentes:', error);
    return res.status(500).json({ message: 'Erro ao buscar viagens pendentes.' });
  }
});


// Endpoint para obter viagens concluídas
app.get('/trips/completed', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM trips WHERE status = "completed"'
    );
    return res.status(200).json(rows);
  } catch (error) {
    console.error('Erro ao buscar viagens concluídas:', error);
    return res.status(500).json({ message: 'Erro ao buscar viagens concluídas.' });
  }
});

app.patch('/trips/:id', async (req, res) => {
  const tripId = req.params.id;
  const { start_location, destination, num_passengers } = req.body;

  if (!start_location || !destination || num_passengers == null) {
    return res.status(400).json({ message: 'Todos os campos são obrigatórios!' });
  }

  try {
    const [result] = await db.query(
      'UPDATE trips SET start_location = ?, destination = ?, num_passengers = ? WHERE id = ?',
      [start_location, destination, num_passengers, tripId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Viagem não encontrada.' });
    }

    return res.status(200).json({ message: 'Viagem atualizada com sucesso!' });
  } catch (error) {
    console.error('Erro ao atualizar viagem:', error);
    return res.status(500).json({ message: 'Erro ao atualizar a viagem.' });
  }
});


app.post('/trips', async (req, res) => {
  const { start_location, destination, created_by, assigned_to, num_passengers } = req.body;

  if (!start_location || !destination || !created_by || !assigned_to || num_passengers == null) {
    return res.status(400).json({ message: 'Todos os campos são obrigatórios!' });
  }

  try {
    const [result] = await db.query(
      'INSERT INTO trips (start_location, destination, created_by, assigned_to, num_passengers) VALUES (?, ?, ?, ?, ?)',
      [start_location, destination, created_by, assigned_to, num_passengers]
    );
    return res.status(201).json({ message: 'Viagem criada com sucesso!', tripId: result.insertId });
  } catch (error) {
    console.error('Erro ao criar viagem:', error);
    return res.status(500).json({ message: 'Erro ao criar a viagem' });
  }
});



app.get('/users/available', async (req, res) => {
  try {
    console.log('Iniciando consulta para utilizadores disponíveis...');

    const [rows] = await db.query(`
      SELECT u.email
      FROM users u
      WHERE NOT EXISTS (
        SELECT 1
        FROM trips t
        WHERE t.assigned_to = u.email AND t.status = 'pending'
      );
    `);

    console.log('Resultado da consulta:', rows);

    const availableUsers = rows.map(user => user.email);

    res.status(200).json(availableUsers);
  } catch (error) {
    console.error('Erro ao buscar utilizadores disponíveis:', error);
    res.status(500).json({ message: 'Erro ao buscar utilizadores disponíveis' });
  }
});




app.patch('/trips/:id/complete', async (req, res) => {
  const tripId = req.params.id;

  try {
    const [result] = await db.query(
      'UPDATE trips SET status = "completed" WHERE id = ?',
      [tripId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Viagem não encontrada' });
    }

    return res.status(200).json({ message: 'Viagem marcada como terminada' });
  } catch (error) {
    console.error('Erro ao atualizar viagem:', error);
    return res.status(500).json({ message: 'Erro ao atualizar o estado da viagem' });
  }
});


app.get('/trips', async (req, res) => {
  const { assigned_to } = req.query; // Altere de `email` para `assigned_to`

  if (!assigned_to) {
    return res.status(400).json({ message: 'O e-mail do utilizador é obrigatório.' });
  }

  try {
    const [rows] = await db.query(
      'SELECT * FROM trips WHERE assigned_to = ? AND status = "pending"',
      [assigned_to] // Substitua por `assigned_to`
    );

    return res.status(200).json(rows); // Retorna apenas viagens pendentes atribuídas ao utilizador
  } catch (error) {
    console.error('Erro ao buscar viagens:', error);
    return res.status(500).json({ message: 'Erro ao buscar viagens.' });
  }
});





// Inicia o servidor
app.listen(3000, () => console.log('Servidor iniciado na porta 3000'));
