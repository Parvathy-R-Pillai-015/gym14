(function() {
    document.addEventListener('DOMContentLoaded', function() {
        const goalTypeField = document.querySelector('select[name="goal_type"]');
        const trainerField = document.querySelector('select[name="uploaded_by"]');
        
        if (!goalTypeField || !trainerField) return;
        
        // Store original value and all options
        const originalValue = trainerField.value;
        const allOptions = Array.from(trainerField.options).slice(); // Clone array
        
        // Filter function with AJAX
        async function filterTrainers() {
            const selectedGoalType = goalTypeField.value;
            
            if (!selectedGoalType) {
                // Show all trainers
                trainerField.innerHTML = '';
                allOptions.forEach(option => {
                    trainerField.appendChild(option.cloneNode(true));
                });
                return;
            }
            
            try {
                const response = await fetch(`/api/users/trainers-by-goal/?goal_type=${selectedGoalType}`);
                const data = await response.json();
                
                if (data.success) {
                    // Clear current options except the empty one
                    trainerField.innerHTML = '<option value="">---------</option>';
                    
                    // Add filtered trainers
                    data.trainers.forEach(trainer => {
                        const option = document.createElement('option');
                        option.value = trainer.id;
                        option.textContent = trainer.name;
                        trainerField.appendChild(option);
                    });
                    
                    // Keep original value if still available, otherwise select first
                    if (Array.from(trainerField.options).some(o => o.value === originalValue)) {
                        trainerField.value = originalValue;
                    } else if (data.trainers.length > 0) {
                        trainerField.value = data.trainers[0].id;
                    }
                }
            } catch (error) {
                console.error('Error fetching trainers:', error);
            }
        }
        
        // Attach change event
        goalTypeField.addEventListener('change', filterTrainers);
        
        // Initial filter if goal_type has a value
        if (goalTypeField.value) {
            filterTrainers();
        }
    });
})();

