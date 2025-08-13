const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Function to send budget overrun alerts
exports.sendBudgetAlert = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    
    // Only process expense transactions
    if (transaction.type !== 'expense') {
      return null;
    }

    try {
      // Get user data
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(transaction.userId)
        .get();
      
      if (!userDoc.exists) {
        return null;
      }

      const userData = userDoc.data();
      const monthlyBudget = userData.monthlyBudget || 0;

      // Calculate current month balance
      const startOfMonth = new Date();
      startOfMonth.setDate(1);
      startOfMonth.setHours(0, 0, 0, 0);

      const endOfMonth = new Date();
      endOfMonth.setMonth(endOfMonth.getMonth() + 1, 0);
      endOfMonth.setHours(23, 59, 59, 999);

      const monthlyTransactions = await admin.firestore()
        .collection('transactions')
        .where('userId', '==', transaction.userId)
        .where('date', '>=', startOfMonth)
        .where('date', '<=', endOfMonth)
        .get();

      let totalIncome = 0;
      let totalExpenses = 0;

      monthlyTransactions.forEach(doc => {
        const tx = doc.data();
        if (tx.type === 'income') {
          totalIncome += tx.amount;
        } else {
          totalExpenses += tx.amount;
        }
      });

      const currentBalance = totalIncome - totalExpenses;
      const budgetUtilization = ((monthlyBudget - currentBalance) / monthlyBudget) * 100;

      // Send alert if budget is over 80% used or negative balance
      if (currentBalance < 0 || budgetUtilization > 80) {
        const message = {
          notification: {
            title: 'GèrTonArgent - Alerte Budget',
            body: currentBalance < 0 
              ? `Budget dépassé! Solde négatif de ${Math.abs(currentBalance).toFixed(0)} FCFA`
              : `Attention! ${budgetUtilization.toFixed(0)}% du budget utilisé`,
          },
          data: {
            type: 'budget_alert',
            balance: currentBalance.toString(),
            budget: monthlyBudget.toString(),
          },
          token: userData.fcmToken, // User's FCM token
        };

        return admin.messaging().send(message);
      }

      return null;
    } catch (error) {
      console.error('Error sending budget alert:', error);
      return null;
    }
  });

// Cloud Function to generate AI spending advice
exports.generateAIAdvice = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { expenseAmount, currentBalance, monthlyBudget, category, recentTransactions } = data;

  try {
    // This is where you would integrate with OpenAI GPT API
    // For now, we'll return a simulated response
    
    const percentageOfBalance = (expenseAmount / currentBalance) * 100;
    const percentageOfBudget = (expenseAmount / monthlyBudget) * 100;

    let advice = '';

    if (percentageOfBalance > 50) {
      advice += `⚠️ Cette dépense représente ${percentageOfBalance.toFixed(0)}% de votre solde actuel. `;
      advice += 'C\'est une dépense importante qui pourrait impacter vos finances. ';
    }

    if (percentageOfBudget > 20) {
      advice += `📊 Cette dépense représente ${percentageOfBudget.toFixed(0)}% de votre budget mensuel. `;
    }

    // Category-specific advice
    switch (category) {
      case 'food':
        if (expenseAmount > 5000) {
          advice += '🍽️ Pour la nourriture, considérez si vous pouvez réduire ce montant en cuisinant à la maison. ';
        }
        break;
      case 'entertainment':
        if (percentageOfBalance > 30) {
          advice += '🎬 Cette dépense de loisirs est importante. Assurez-vous qu\'elle en vaut vraiment la peine. ';
        }
        break;
      case 'shopping':
        advice += '🛍️ Avant d\'acheter, demandez-vous si cet article est vraiment nécessaire. ';
        break;
      case 'transport':
        if (expenseAmount > 3000) {
          advice += '🚗 Considérez les alternatives moins chères comme le transport en commun. ';
        }
        break;
    }

    if (currentBalance - expenseAmount < monthlyBudget * 0.1) {
      advice += '🚨 ATTENTION: Après cette dépense, il vous restera très peu pour le reste du mois. ';
      advice += 'Considérez reporter cette dépense si possible.';
    } else if (advice.isEmpty) {
      advice = '✅ Cette dépense semble raisonnable. Continuez votre bonne gestion financière!';
    }

    return { advice };
  } catch (error) {
    console.error('Error generating AI advice:', error);
    throw new functions.https.HttpsError('internal', 'Error generating advice');
  }
});

// Cloud Function to update user's FCM token
exports.updateFCMToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { fcmToken } = data;
  const userId = context.auth.uid;

  try {
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .update({ fcmToken });

    return { success: true };
  } catch (error) {
    console.error('Error updating FCM token:', error);
    throw new functions.https.HttpsError('internal', 'Error updating token');
  }
});

// Cloud Function to send daily financial summary
exports.sendDailySummary = functions.pubsub.schedule('0 20 * * *').onRun(async (context) => {
  try {
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .get();

    const today = new Date();
    const startOfDay = new Date(today);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(today);
    endOfDay.setHours(23, 59, 59, 999);

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      if (!userData.fcmToken) continue;

      // Get today's transactions
      const todayTransactions = await admin.firestore()
        .collection('transactions')
        .where('userId', '==', userDoc.id)
        .where('date', '>=', startOfDay)
        .where('date', '<=', endOfDay)
        .get();

      let totalIncome = 0;
      let totalExpenses = 0;

      todayTransactions.forEach(doc => {
        const tx = doc.data();
        if (tx.type === 'income') {
          totalIncome += tx.amount;
        } else {
          totalExpenses += tx.amount;
        }
      });

      if (totalIncome > 0 || totalExpenses > 0) {
        const message = {
          notification: {
            title: 'GèrTonArgent - Résumé quotidien',
            body: `Aujourd'hui: +${totalIncome.toFixed(0)} FCFA, -${totalExpenses.toFixed(0)} FCFA`,
          },
          data: {
            type: 'daily_summary',
            income: totalIncome.toString(),
            expenses: totalExpenses.toString(),
          },
          token: userData.fcmToken,
        };

        await admin.messaging().send(message);
      }
    }

    return null;
  } catch (error) {
    console.error('Error sending daily summary:', error);
    return null;
  }
});
