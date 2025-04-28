layui.use(['form'], function() {
    const form = layui.form;
    form.render();
});

function submitFixedRule() {
    const form = document.getElementById('fixedRuleForm');
    const data = {
        studentName: form.studentName.value.trim(),
        dayOfWeek: parseInt(form.dayOfWeek.value),
        effectiveFrom: form.effectiveFrom.value,
        effectiveTo: form.effectiveTo.value || null
    };

    axios.post('http://localhost:5242/api/aftercare_rules', data)
        .then(res => {
            layer.msg('Fixed rule registered successfully');
            form.reset();
        })
        .catch(err => {
            console.error(err);
            layer.msg('Failed to register fixed rule');
        });
}

function submitOneTime() {
    const form = document.getElementById('oneTimeForm');
    const data = {
        studentName: form.studentName.value.trim(),
        aftercareDate: form.aftercareDate.value
    };

    axios.post('http://localhost:5242/api/aftercare_onetime', data)
        .then(res => {
            layer.msg('One-time aftercare registered successfully');
            form.reset();
        })
        .catch(err => {
            console.error(err);
            layer.msg('Failed to register one-time aftercare');
        });
}
