<template>
  <div id="home">
    <form class="box" @submit.prevent="submit">
      <p class="text-lg">You can add up to 2 selections and its percentage.</p>

      <div v-if="error" class="alert alert-danger mb-lg">
        {{ error }}
      </div>

      <div class="flex center mt-sm text-left relative">
        <div class="mr-md col-50">
          <label for="fs" class="label cursor-pointer">
            First Selection
          </label>
          <input id="fs" type="text" class="input" v-model="fs">
        </div>
        <div class="col-50">
          <label for="fp" class="label cursor-pointer">
            First Selection percentage
          </label>
          <div>
            <input id="fp" type="number" class="input" v-model="fp">
          </div>
        </div>
      </div>

      <div class="flex center mt-sm text-left relative">
        <div class="mr-md col-50">
          <label for="fs" class="label cursor-pointer">
            Second Selection
          </label>
          <input id="fs" type="text" class="input" v-model="ss">
        </div>
        <div class="col-50">
          <label for="fp" class="label cursor-pointer">
            Second Selection percentage
          </label>
          <div>
            <input id="fp" type="number" class="input" v-model="sp">
          </div>
        </div>
      </div>

      <div class="flex center mt-sm text-left relative">
        <div class="mr-md col-50">
          <label for="uc" class="label cursor-pointer">
            Past Date
          </label>
          <input id="uc" type="date" class="input" v-model="form.date">
        </div>
        <div class="col-50">
          <label for="ut" class="label cursor-pointer">
            $ Amount
          </label>
          <div>
            <input id="ut" type="text" class="input" v-model="form.amount">
          </div>
        </div>
      </div>

      <div class="mt-md">
        <button class="btn mr-md" type="submit">Submit</button>
        <button class="btn" type="reset">Reset</button>
      </div>
    </form>

    <div v-if="loading" id="loading">
      <h4>Loading...</h4>
    </div>

    <div v-if="result" class="mt-lg">
      <h3>Result:</h3>
      <div class="mb-md">
        <p class="text-lg">
          Results for date: <b>{{ form.date }}</b>
        </p>
        <ul>
          <li v-for="item in result.data.data.data" class="mb-lg">
            <h4>{{ item.name }}</h4>
            <p>
              Closed at: <b>${{ item.close }}</b> - <b>{{ item.total }}</b> stock for <b>${{ item.amount }}</b>.
            </p>
            <p>
              Today stock price: <b>${{item.actual}}</b>
              <br>
              Total value now: <b>${{ get_total(item.total, item.actual) }}</b>
              <br>
              Profit of: <b>${{ get_profit(item.total, item.actual, item.amount) }}</b>
            </p>
          </li>
          <div class="mt-md">
            <h3>Request URL</h3>
            You can request again your data with this URL:
            <br>
            <b>{{ get_url(result.data.data.url) }}</b>
          </div>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
import axios from '../axios'

export default {
  name: 'Home',
  data () {
    return {
      form: {
        symbols: [],
        date: '',
        amount: 10000
      },
      loading: false,
      fs: 'GOOG',
      fp: 50,
      ss: 'TWTR',
      sp: 50,
      error: null,
      result: null
    }
  },
  methods: {
    reset () {
      this.error = null
      this.result = null
      this.form.symbols = []
    },
    round(value, decimals) {
      return Number(Math.round(value+'e2')+'e-2')
    },
    get_total(total, actual) {
      return this.round(total * actual)
    },
    get_profit(total, actual, amount) {
      return this.round(this.get_total(total, actual) - amount)
    },
    get_url(url) {
      return window.location.href + '?id=' + url
    },

    submit () {
      console.log('Submiting')
      this.loading = true
      this.reset()

      // Set numeric params as integers
      const p1 = parseInt(this.fp)
      const p2 = parseInt(this.sp)
      this.form.symbols.push({ name: this.fs, percentage: p1 })
      this.form.symbols.push({ name: this.ss, percentage: p2 })
      this.form.amount = parseInt(this.form.amount)

      if (!this.form.date || !this.form.symbols.length || !this.form.amount) {
        this.error = 'All fields are required.'
      } else if (p1 + p2 > 100) {
        this.error = 'Percentage given is over 100.'
      } else {
        axios.post('/', this.form)
          .then((response) => {
            console.log(response)
            this.result = response
          })
          .catch((err) => {
            console.error(err)
            if (err.data) return this.error = err.data.message
            this.error = err
          })
      }
      this.$nextTick(() => {
        this.loading = false
      })
    }
  }
}
</script>
